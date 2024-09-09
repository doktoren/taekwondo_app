"""
This python module implements the lambda function that can be found accessible at
https://eu-central-1.console.aws.amazon.com/lambda/home?region=eu-central-1

Testing with `curl -X POST -d <data> -H "Content-type: application/json" <url>`
Url for test setup is `'https://giiucpryj6hizlsgwvoezpzura0cvcsg.lambda-url.eu-central-1.on.aws/'`

Example data, response pairs are shown below.
In every request an action and authentication token must be passed.
The authentication token is only returned by two actions: "admin_create_user" and "admin_retrieve_auth_token".
Every action is refixed with the required role, lower cased, followed by an underscore.

The implementation does validation of every request to the endpoint.
However, it assumes that only valid configurations are ever stored in the S3 objects.


Admin actions

```
{"action": "admin_create_user", "auth_token": "tEYhxhie", "name": "David", "role": "Student"}
=>
{
    "user_id": "f8b12140-3e72-4dfa-99f3-3b4486af0018",
    "name": "David",
    "role": "Student",
    "auth_token": "bDje23kk"
}

{
    "action": "admin_update_user", "auth_token": "tEYhxhie",
    "user_id": "f8b12140-3e72-4dfa-99f3-3b4486af0018", "name": "David", "role": "Student"
}
=>
{}

{"action": "admin_delete_user", "auth_token": "tEYhxhie", "user_id": "f8b12140-3e72-4dfa-99f3-3b4486af0018"}
=>
{}

{"action": "admin_show_auth_token", "auth_token": "tEYhxhie", "user_id": "f8b12140-3e72-4dfa-99f3-3b4486af0018"}
=>
{"auth_token": "5635a8d1-b8a1-42f7-af20-4e544b5773ee"}
```

Coach actions

```
{
    "action": "coach_add_training_session", "auth_token": "tEYhxhie",
    "start_time": 1727370000, "end_time": 1727375400,
    "coach": "df11c4d5-d5a3-4da0-ad96-44aca7519df6",
    "comment": "Dtaf-Pensumtræning - Træning foregår på squashbanen"
}
=>
{
    "session_id": "e3058f7e-4d45-4d55-9047-7f46db2cf9ff",
    "start_time": 1727370000,
    "end_time": 1727375400,
    "coach": "df11c4d5-d5a3-4da0-ad96-44aca7519df6",
    "comment": "Dtaf-Pensumtræning - Træning foregår på squashbanen",
    "state": "scheduled",
}

{
    "action": "coach_update_training_session", "auth_token": "tEYhxhie",
    "session_id": "e3058f7e-4d45-4d55-9047-7f46db2cf9ff",
    "start_time": 1727370000, "end_time": 1727375400,
    "coach": "df11c4d5-d5a3-4da0-ad96-44aca7519df6",
    "comment": "Dtaf-Pensumtræning - Træning foregår på squashbanen"
}
=>
{}

{
    "action": "coach_update_training_session", "auth_token": "tEYhxhie",
    "session_id": "e3058f7e-4d45-4d55-9047-7f46db2cf9ff", "session_state": "cancelled"
}
=>
{}

{
    "action": "coach_register_participation", "auth_token": "tEYhxhie",
    "session_id": "e3058f7e-4d45-4d55-9047-7f46db2cf9ff",
    "participants": [
        "3f3cc172-b86d-49a4-b20b-c3c4a2649aed",
        "13f09279-e6b6-46d4-b76b-4c0aae2ae13b",
        "1ce45c1b-83cc-4776-9420-490e70abe23a",
        "b3307371-6cfc-4252-a6af-b90b6efc8079",
    ]
}
=>
{}


{
    "action": "coach_get_historical_participation", "auth_token": "tEYhxhie",
    "start_time": 1700000000, "end_time": 1727375400,
}
=>
{
    // Session id
    "e3058f7e-4d45-4d55-9047-7f46db2cf9ff": {
        "session": {
            "start_time": 1727370000,
            "end_time": 1727375400,
            "coach": "df11c4d5-d5a3-4da0-ad96-44aca7519df6",
            "comment": "Dtaf-Pensumtræning - Træning foregår på squashbanen",
        },
        "participants": [
            "f8b12140-3e72-4dfa-99f3-3b4486af0018",
            // Etc.
        ]
    },
    // Etc.
}
```


Multi-user actions

```
{"action": "any_trigger_initialization"}
=>
{}
```

```
{
    "action": "any_register_participation",
    "joining_sessions": {
        "e3058f7e-4d45-4d55-9047-7f46db2cf9ff": "Yes",
        "613158da-a7a5-4737-bb41-a63bf154f99b": "No",
    },
    "user_auth_tokens": ["tEYhxhie"],
}
=>
{}
```

```
{"action": "any_reset_test_setup", "test_secret": "secret"}
=>
{}
```
"""

import base64
import datetime
import hashlib
import json
import logging
import os
import string
import time
import unicodedata
from copy import deepcopy
from functools import wraps
from random import Random, SystemRandom
from typing import (
    TYPE_CHECKING,
    Any,
    Callable,
    Final,
    Literal,
    Mapping,
    NewType,
    NotRequired,
    TypeAlias,
    TypedDict,
    TypeVar,
    cast,
    get_args,
)
from uuid import uuid4

from botocore.exceptions import ClientError
from botocore.session import Session

if TYPE_CHECKING:
    from aws_lambda_powertools.utilities.typing import LambdaContext
else:
    LambdaContext = type(None)

PUBLIC_BUCKET_NAME: Final = os.environ["PUBLIC_BUCKET_NAME"]
PRIVATE_BUCKET_NAME: Final = os.environ["PRIVATE_BUCKET_NAME"]
TEST_SECRET: Final = os.getenv("TEST_SECRET")  # The action "reset_test_setup" requires this secret

logger = logging.getLogger()
logger.setLevel(logging.INFO)

RoleT: TypeAlias = Literal["Admin", "Coach", "Student"]
RoleOrAnyT: TypeAlias = Literal["Admin", "Coach", "Student", "Any"]
assert set(get_args(RoleT)) <= set(get_args(RoleOrAnyT))
EpochT = NewType("EpochT", int)
YesNoT: TypeAlias = Literal["Yes", "No"]
YesNoMaybeT: TypeAlias = Literal["Yes", "No", "Maybe"]
SessionStateT: TypeAlias = Literal["archived", "cancelled", "scheduled"]


def role_includes(role_a: RoleT, role_b: RoleT) -> bool:
    """
    Return True if role_a can be used as role_b
    """
    return role_a <= role_b


class User(TypedDict):
    """
    The user information created by admin
    """

    user_id: str
    name: str
    role: RoleT
    auth_token: str  # or a hash of it


class TrainingSession(TypedDict):
    """
    The data for a single training session
    """

    session_id: str
    start_time: EpochT
    end_time: EpochT
    state: SessionStateT
    coach: NotRequired[str]
    comment: NotRequired[str]
    participation: dict[str, YesNoMaybeT]


class Data(TypedDict):
    """
    All admin data
    """

    users: dict[str, User]
    sessions: dict[str, TrainingSession]


class Participation(TypedDict):
    """
    The historical data for a single training session
    """

    session: TrainingSession  # A copy of the session data
    participants: list[str]  # Ordered list of user_ids


F = TypeVar("F", bound=Callable[..., Any])


def log_execution_time(func: F) -> F:
    """
    Logs the execution time of the function in milliseconds.
    """

    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        start_time: float = time.time()
        result: Any = func(*args, **kwargs)
        end_time: float = time.time()
        execution_time: float = (end_time - start_time) * 1000  # convert to milliseconds
        logger.info(f"Executed {func.__name__} in {execution_time:.2f} ms")
        return result

    return wrapper  # type: ignore


def hash_token(auth_token: str) -> str:
    """
    Return the SHA256 hash of the auth_token

    This is included instead of the auth_token in the public data on S3.
    This allows the user to validate its auth_token without quering this Lambda Function.
    """
    sha256_hash = hashlib.sha256()
    sha256_hash.update(auth_token.encode("utf-8"))
    return sha256_hash.hexdigest()


def make_auth_token(random: Random | None = None) -> str:
    """
    Creates a new login token for a user
    """
    return "".join((random or SystemRandom()).choice(string.ascii_letters + string.digits) for _ in range(8))


def make_id() -> str:
    """
    Creates a new id string
    """
    return str(uuid4())


def make_default_data() -> Data:
    """
    Creates a small valid dataset
    """
    default_admin_id = make_id()

    time_now = time.time()
    session_1_start_time = 1727370000
    while session_1_start_time < time_now:
        session_1_start_time += 604800
    session_2_start_time = 1727802000
    while session_2_start_time < time_now:
        session_2_start_time += 604800

    return Data(
        users={
            default_admin_id: User(
                user_id=default_admin_id,
                role="Admin",
                name="Default admin",
                auth_token=make_auth_token(),
            ),
        },
        sessions={},
    )


def make_test_data() -> tuple[Data, dict[str, Participation]]:  # pylint: disable=too-many-locals
    """
    Creates a small valid dataset
    """
    admin_id = "01ebbd39-3f48-43d5-89c4-98383d185a27"
    tuesday_coach_id = "5bca8421-f626-4358-b51e-57f8f81aaeba"
    thursday_coach_id = "252451bc-b589-4f63-bbaa-9451da6f2baf"
    current_coach_id = "6ecd9949-0896-4cac-a7f8-e187f239f7bf"
    student_id_1 = "0dbb7c34-bcdc-4ebf-9885-1fd43813e399"
    student_id_2 = "2c78ebd0-6f60-48f4-b646-61c7e0f628e2"
    student_id_3 = "a46bf3f0-1b1d-4653-8475-8fad32f68576"
    student_id_4 = "de9aafd4-2959-4ede-a49d-25daf653084c"
    student_id_5 = "e3bdc941-ea0f-4c96-9ed2-829847df3f64"
    student_id_6 = "303dfb6e-94a5-4b2c-b838-9c6315b90789"

    session_1_id = "c777d1d8-70aa-4d6a-8bf0-cce83c9cdfa6"
    session_2_id = "7a067a85-43c7-40b5-a9ad-ce4b5e1b3266"
    current_session_id = "c7531477-067b-4916-8558-4ab2dea22c5c"

    time_now = time.time()
    tuesday_session_start_time = 1727370000
    while tuesday_session_start_time < time_now:
        tuesday_session_start_time += 604800
    thursday_session_start_time = 1727802000
    while thursday_session_start_time < time_now:
        thursday_session_start_time += 604800
    current_session_start_time = int(time_now) // 3600 * 3600

    # Deterministic randomness such that the login codes remain the same
    random = Random(42)
    data = Data(
        users={
            admin_id: User(
                user_id=admin_id,
                role="Admin",
                name="Grandmaster ByteFist",
                auth_token=make_auth_token(random),
            ),
            tuesday_coach_id: User(
                user_id=tuesday_coach_id,
                role="Coach",
                name="Black Belt Betty",
                auth_token=make_auth_token(random),
            ),
            thursday_coach_id: User(
                user_id=thursday_coach_id,
                role="Coach",
                name="Flying Foot Fred",
                auth_token=make_auth_token(random),
            ),
            current_coach_id: User(
                user_id=current_coach_id,
                role="Coach",
                name="Poomsae Pam",
                auth_token=make_auth_token(random),
            ),
            student_id_1: User(
                user_id=student_id_1,
                role="Student",
                name="Tornado Todd",
                auth_token=make_auth_token(random),
            ),
            student_id_2: User(
                user_id=student_id_2,
                role="Student",
                name="HighKick Heidi",
                auth_token=make_auth_token(random),
            ),
            student_id_3: User(
                user_id=student_id_3,
                role="Student",
                name="Choppy Charlie",
                auth_token=make_auth_token(random),
            ),
            student_id_4: User(
                user_id=student_id_4,
                role="Student",
                name="PowerKick Parker",
                auth_token=make_auth_token(random),
            ),
            student_id_5: User(
                user_id=student_id_5,
                role="Student",
                name="Taekwon Todd",
                auth_token=make_auth_token(random),
            ),
            student_id_6: User(
                user_id=student_id_6,
                role="Student",
                name="Lazy Joe",
                auth_token=make_auth_token(random),
            ),
        },
        sessions={
            session_1_id: TrainingSession(
                session_id=session_1_id,
                start_time=EpochT(tuesday_session_start_time),
                end_time=EpochT(tuesday_session_start_time + 5400),
                coach=tuesday_coach_id,
                comment="Practice for the upcoming graduation",
                state="scheduled",
                participation={
                    student_id_1: "Yes",
                    student_id_2: "Yes",
                    student_id_3: "Yes",
                    student_id_5: "Maybe",
                    student_id_6: "No",
                },
            ),
            session_2_id: TrainingSession(
                session_id=session_2_id,
                start_time=EpochT(thursday_session_start_time),
                end_time=EpochT(thursday_session_start_time + 5400),
                coach=thursday_coach_id,
                comment="Self-defense training",
                state="scheduled",
                participation={
                    student_id_1: "Yes",
                    student_id_2: "No",
                    student_id_3: "Maybe",
                    student_id_4: "Yes",
                    student_id_5: "Yes",
                    student_id_6: "No",
                },
            ),
            current_session_id: TrainingSession(
                session_id=current_session_id,
                start_time=EpochT(current_session_start_time),
                end_time=EpochT(current_session_start_time + 5400),
                coach=current_coach_id,
                comment="Kicks and stamina training",
                state="scheduled",
                participation={
                    student_id_1: "Yes",
                    student_id_2: "No",
                    student_id_3: "Yes",
                    student_id_4: "Yes",
                    student_id_5: "Yes",
                    student_id_6: "No",
                },
            ),
        },
    )

    def historic_participation(session: TrainingSession, n_weeks_ago: int) -> Participation:
        session = TrainingSession(**session)
        session["session_id"] = make_id()
        session["start_time"] = EpochT(session["start_time"] - 604800 * n_weeks_ago)
        session["end_time"] = EpochT(session["end_time"] - 604800 * n_weeks_ago)
        return Participation(
            session=session | {},
            participants=sorted(participant_id for participant_id in session["participation"] if random.random() < 0.8),
        )

    historic_data: dict[str, Participation] = {}
    for n_weeks_ago in range(1, 20):
        for session_id in [session_1_id, session_2_id]:
            participation = historic_participation(data["sessions"][session_id], n_weeks_ago)
            historic_data[participation["session"]["session_id"]] = participation

    return data, historic_data


class ArgumentError(Exception):
    """
    These exceptions will cause a 400 response
    """


# Define a global boto3 client to avoid creating a new client for every request
# (the instance is short lived though, so this probably won't help that much)
S3_CLIENT: Any = None


@log_execution_time
def create_s3_client() -> Any:
    """
    Creates an S3 client using botocore
    """
    global S3_CLIENT  # pylint: disable=global-statement
    if S3_CLIENT is None:
        session = Session()
        S3_CLIENT = session.create_client("s3")  # Very slow operation!
    return S3_CLIENT


class Backend:
    """
    Communication with S3 backend

    All attributes that are NOT _ prefixed must be methods taking self and dict[str, Any] as
    arguments and returning dict[str, Any]
    """

    @log_execution_time
    def __init__(self) -> None:
        self._client: Final = create_s3_client()
        try:
            self._data = cast(Data, self._read_from_private_s3("data.json"))
        except ClientError as e:
            if e.response["Error"]["Code"] == "NoSuchKey":
                self._data = make_default_data()
                self._save_data()
            else:
                raise

    @log_execution_time
    def _read_from_private_s3(self, key: str) -> dict[str, Any]:
        response = self._client.get_object(Bucket=PRIVATE_BUCKET_NAME, Key=key)
        body_dict = cast(dict[str, Any], json.loads(response["Body"].read().decode("utf-8")))
        return body_dict

    @log_execution_time
    def _write_to_private_s3(self, data: Mapping[str, Any], key: str) -> None:
        self._client.put_object(
            Body=json.dumps(data),
            Bucket=PRIVATE_BUCKET_NAME,
            Key=key,
        )

    @log_execution_time
    def _write_to_public_s3(self, data: Mapping[str, Any], key: str) -> None:
        self._client.put_object(Body=json.dumps(data), Bucket=PUBLIC_BUCKET_NAME, Key=key)

    @log_execution_time
    def _save_data(self) -> None:
        data = self._filter_old_data()
        self._write_to_private_s3(
            data=data,
            key="data.json",
        )
        self._write_to_public_s3(
            data=data
            | {
                "users": {
                    user_id: user | {"auth_token": hash_token(user["auth_token"])}
                    for user_id, user in data["users"].items()
                }
            },
            key="data.json",
        )

    def _filter_old_data(self) -> dict[str, Any]:
        """
        Remove old data from self._data
        """
        data: dict[str, Any] = dict(deepcopy(self._data))
        time_now = time.time()
        for session_id, session in list(data["sessions"].items()):
            if session["state"] == "archived" and session["end_time"] + 43200 < time_now:
                data["sessions"].pop(session_id)
        return data

    def _get_caller(self, data: Mapping[str, Any]) -> User:
        for user in self._data["users"].values():
            if user["auth_token"] == data.get("auth_token"):
                return user
        raise ArgumentError("Authentication token not provided or not recognized")

    def _get_caller_or_none(self, data: Mapping[str, Any]) -> User | None:
        if not data.get("auth_token"):
            return None
        return self._get_caller(data)

    @log_execution_time
    def authenticate(self, data: Mapping[str, Any]) -> None:
        """
        Validates data["auth_token"] according to data["action"]
        """
        if (
            (action := data.get("action")) is None
            or not isinstance(action, str)
            or action.startswith("_")
            or "_" not in action
        ):
            raise ArgumentError(f"Invalid or missing action: {action}")

        tmp = action.split("_")[0]
        tmp = tmp[0].upper() + tmp[1:]
        if tmp not in get_args(RoleOrAnyT):
            raise ArgumentError(f"Invalid prefix {tmp} for action: {action}")
        role = cast(RoleOrAnyT, tmp)

        if role == "Any":
            return
        user = self._get_caller(data)
        if not role_includes(cast(RoleT, user["role"]), role):
            raise ArgumentError(f"User is not authorized for role {role}")

    def admin_create_user(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Create a new user.
        """
        role, name = parse(data, [("role", str), ("name", str)])  # pylint: disable=unbalanced-tuple-unpacking
        if role not in get_args(RoleT):
            raise ArgumentError(f"Invalid role: {role}")
        name = unicodedata.normalize("NFKC", name.strip())
        if not 3 <= len(name) <= 60:
            raise ArgumentError("Name must have length in [3..60] (after normalization)")
        if any(name == user["name"] for user in self._data["users"].values()):
            raise ArgumentError("Name already in use")
        user_id = make_id()
        user = User(
            user_id=user_id,
            role=cast(RoleT, role),
            name=name,
            auth_token=make_auth_token(),
        )
        self._data["users"][user["user_id"]] = user
        self._save_data()
        return user

    def admin_update_user(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Update a user.
        """
        user_id, role, name = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data, [("user_id", str), ("role", str), ("name", str)]
        )
        if (user := self._data["users"].get(user_id)) is None:
            raise ArgumentError(f"User with id {user_id} not found")
        if role not in get_args(RoleT):
            raise ArgumentError(f"Invalid role: {role}")
        if not 3 <= len(name) <= 60:
            raise ArgumentError("Name must have length in [3..60]")

        user["role"] = cast(RoleT, role)
        user["name"] = name
        self._save_data()
        return {}

    def admin_delete_user(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Deletes a user
        """
        (user_id,) = parse(data, [("user_id", str)])  # pylint: disable=unbalanced-tuple-unpacking
        user = self._data["users"].pop(user_id, None)
        if user is None:
            raise ArgumentError(f"User with id {user_id} not found")
        if user is self._get_caller(data):
            raise ArgumentError("Cannot delete yourself")
        self._save_data()
        return {}

    def admin_show_auth_token(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Returns the private auth_token for a user
        """
        (user_id,) = parse(data, [("user_id", str)])  # pylint: disable=unbalanced-tuple-unpacking
        if (user := self._data["users"].get(user_id)) is None:
            raise ArgumentError(f"User with id {user_id} not found")
        return {"auth_token": user["auth_token"]}

    def any_register_participation(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Register one of more users intended participation ("Yes"/"No"/"Maybe"/None) to one or more training sessions.

        None means unspecified/no information - the participance information is removed.
        """
        (joining_sessions, user_auth_tokens) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("joining_sessions", dict),
                ("user_auth_tokens", list),
            ],
        )
        if not all(
            isinstance(session_id, str) and isinstance(joining, str) for session_id, joining in joining_sessions.items()
        ):
            raise ArgumentError("Invalid session data type")
        if any(self._data["sessions"].get(session_id) is None for session_id in joining_sessions):
            raise ArgumentError("One or more unrecognized session ids")
        if not all(joining is None or joining in get_args(YesNoMaybeT) for joining in joining_sessions.values()):
            raise ArgumentError("One or more invalid values for joining")
        if not all(isinstance(auth_token, str) for auth_token in user_auth_tokens):
            raise ArgumentError("user_auth_tokens must be a list of strings")

        user_auth_tokens_set = set(user_auth_tokens)
        identified_users = []
        for user in self._data["users"].values():
            if user["auth_token"] in user_auth_tokens_set:
                identified_users.append(user)

        for session_id, joining in joining_sessions.items():
            session = self._data["sessions"][session_id]
            for user in identified_users:
                if joining:
                    session["participation"][user["user_id"]] = joining
                else:
                    session["participation"].pop(user["user_id"], None)

        self._save_data()
        return {}

    def any_trigger_initialization(  # pylint: disable=unused-argument
        self, data: Mapping[str, Any]
    ) -> Mapping[str, Any]:
        """
        This endpoint only exists to trigger the initialization of the backend data
        """
        return {}

    def any_reset_test_setup(self, data: Mapping[str, Any]) -> Mapping[str, Any]:  # pylint: disable=unused-argument
        """
        This requires the environment variable TEST_SECRET to be set.
        It leaves the backend in a clean state, ready for testing.
        """
        if not TEST_SECRET:
            raise ArgumentError("TEST_SECRET is not defined in the backend")
        if data.get("test_secret") != TEST_SECRET:
            raise ArgumentError("Invalid test secret")
        self._data, historic_data = make_test_data()
        self._save_data()

        historic_data_this_year = {}
        historic_data_last_year = {}
        yyyy_this = datetime.datetime.fromtimestamp(int(time.time()), datetime.timezone.utc).strftime("%Y")
        yyyy_last = str(int(yyyy_this) - 1)
        for participation in historic_data.values():
            yyyy = datetime.datetime.fromtimestamp(
                participation["session"]["start_time"], datetime.timezone.utc
            ).strftime("%Y")
            if yyyy == yyyy_this:
                historic_data_this_year[participation["session"]["session_id"]] = participation
            else:
                historic_data_last_year[participation["session"]["session_id"]] = participation

        if historic_data_this_year:
            self._write_to_private_s3(data=historic_data_this_year, key=f"sessions/participation_data_{yyyy_this}.json")
        if historic_data_last_year:
            self._write_to_private_s3(data=historic_data_last_year, key=f"sessions/participation_data_{yyyy_last}.json")

        return {}

    def coach_add_training_session(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Add a training session
        """
        (start_time, end_time, coach, comment) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("start_time", int),
                ("end_time", int),
                ("coach", str | None),
                ("comment", str | None),
            ],
        )
        if coach not in self._data["users"]:
            raise ArgumentError(f"Unrecognized coach: {coach}")
        session_id = make_id()
        session = TrainingSession(
            session_id=session_id,
            start_time=start_time,
            end_time=end_time,
            state="scheduled",
            coach=coach,
            comment=comment,
            participation={coach: "Yes"},
        )
        self._data["sessions"][session_id] = session
        self._save_data()
        return {"session": session}

    def _coach_set_training_session_state(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Changes the state of a training session
        """
        (session_id, session_state) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("session_id", str),
                ("session_state", str),
            ],
        )
        if (session := self._data["sessions"].get(session_id)) is None:
            raise ArgumentError(f"Unrecognized session id: {session_id}")
        if session_state == "deleted":
            self._data["sessions"].pop(session_id)
        else:
            if session_state not in get_args(SessionStateT):
                raise ArgumentError(f"Unrecognized session state: {session_state}")
            session["state"] = session_state
        self._save_data()
        return {}

    def coach_update_training_session(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Update a training session
        """
        if "session_state" in data:
            return self._coach_set_training_session_state(data)
        (session_id, start_time, end_time, coach, comment) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("session_id", str),
                ("start_time", int),
                ("end_time", int),
                ("coach", str | None),
                ("comment", str | None),
            ],
        )
        if (session := self._data["sessions"].get(session_id)) is None:
            raise ArgumentError(f"Unrecognized session id: {session_id}")
        if self._data["sessions"][session_id]["state"] != "scheduled":
            raise ArgumentError(f"Session is not scheduled: {session_id}")
        if coach not in self._data["users"]:
            raise ArgumentError(f"Unrecognized coach: {coach}")

        session["start_time"] = start_time
        session["end_time"] = end_time
        session["coach"] = coach
        session["comment"] = comment
        self._save_data()
        return {"session": session}

    def coach_register_participation(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Register who actually showed up to a training session.
        """
        (session_id, participants) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("session_id", str),
                ("participants", list),
            ],
        )
        if (session := self._data["sessions"].get(session_id)) is None:
            raise ArgumentError(f"Unrecognized session id: {session_id}")
        if self._data["sessions"][session_id]["state"] not in ["scheduled", "archived"]:
            raise ArgumentError(f"Session is not scheduled or archived: {session_id}")
        if time.time() < session["start_time"] - 600:
            raise ArgumentError("Training session wont start for at least another 10 minutes - too early to register")
        if not all(isinstance(user_id, str) for user_id in participants):
            raise ArgumentError(f"Each participant must be a string id: {participants}")
        if not set(participants) <= set(self._data["users"]):
            raise ArgumentError(f"Unrecognized users: {set(participants) - set(self._data['users'])}")

        yyyy = datetime.datetime.fromtimestamp(session["start_time"], datetime.timezone.utc).strftime("%Y")
        key = f"sessions/participation_data_{yyyy}.json"
        try:
            history: dict[str, Participation] = self._read_from_private_s3(key=key)
        except ClientError as e:
            if e.response["Error"]["Code"] == "NoSuchKey":
                history = {}

        participants.sort()
        history[session_id] = Participation(
            session=session,
            participants=participants,
        )
        self._write_to_private_s3(data=history, key=key)

        self._data["sessions"][session_id]["state"] = "archived"
        self._save_data()
        return {}

    def coach_get_historical_participation(self, data: Mapping[str, Any]) -> Mapping[str, Any]:
        """
        Return historical participation data.

        Return data for all historical sessions where the session start_time is in the range [start_time, end_time[
        """
        (start_time, end_time) = parse(  # pylint: disable=unbalanced-tuple-unpacking
            data,
            [
                ("start_time", int),
                ("end_time", int),
            ],
        )
        if start_time >= end_time:
            raise ArgumentError(f"Invalid time range: {start_time} >= {end_time}")
        if start_time < 1700000000:
            raise ArgumentError(f"Invalid start time (too far in the past): {start_time}")
        if end_time > time.time() + 31 * 86400:
            raise ArgumentError(f"Invalid end time (in the future): {end_time}")

        yyyy_first = int(datetime.datetime.fromtimestamp(start_time, datetime.timezone.utc).strftime("%Y"))
        yyyy_last = int(datetime.datetime.fromtimestamp(end_time - 1, datetime.timezone.utc).strftime("%Y"))

        result = {}
        for yyyy in range(yyyy_first, yyyy_last + 1):
            key = f"sessions/participation_data_{yyyy}.json"
            try:
                history: dict[str, Participation] = self._read_from_private_s3(key=key)
            except ClientError as e:
                if e.response["Error"]["Code"] == "NoSuchKey":
                    continue

            for session_id, participation in history.items():
                if start_time <= participation["session"]["start_time"] < end_time:
                    result[session_id] = {
                        "session": {
                            "start_time": participation["session"]["start_time"],
                            "end_time": participation["session"]["end_time"],
                            "coach": participation["session"]["coach"],
                            "comment": participation["session"]["comment"],
                        },
                        "participants": participation["participants"],
                    }

        return result


class HttpT(TypedDict):
    """
    Convenience definition based on the observed content
    """

    method: str  # "GET"
    path: str  # "/"
    protocol: str  # "HTTP/1.1"
    sourceIp: str  # "87.116.16.2"
    userAgent: str  # "curl/8.5.0"


class RequestContextT(TypedDict):
    """
    Convenience definition based on the observed content
    """

    accountId: str  # "anonymous"
    apiId: str  # "r3q25puk2gjbk5oq6ommfbyjye0tnnno"
    domainName: str  # "r3q25puk2gjbk5oq6ommfbyjye0tnnno.lambda-url.us-east-1.on.aws"
    domainPrefix: str  # "r3q25puk2gjbk5oq6ommfbyjye0tnnno"
    http: HttpT
    requestId: str  # "bdf75011-1e08-4012-ac10-c1e8b70a5eff"
    routeKey: str  # "$default"
    stage: str  # "$default"
    time: str  # "25/Sep/2024:10:04:25 +0000"
    timeEpoch: int  # 1727258665141


class EventT(TypedDict):
    """
    Convenience definition based on the observed content
    """

    version: str  # '2.0'
    routeKey: str  # '$default'
    rawPath: str  # '/'
    rawQueryString: str  # ''
    # {
    #     "x-amzn-tls-cipher-suite": "TLS_AES_128_GCM_SHA256",
    #     "x-amzn-tls-version": "TLSv1.3",
    #     "x-amzn-trace-id": "Root=1-66f3e029-1ae02d8702cf40d870ae53e4",
    #     "x-forwarded-proto": "https",
    #     "host": "r3q25puk2gjbk5oq6ommfbyjye0tnnno.lambda-url.us-east-1.on.aws",
    #     "x-forwarded-port": "443",
    #     "x-forwarded-for": "87.116.16.2",
    #     "accept": "*/*",
    #     "user-agent": "curl/8.5.0",
    # }
    headers: dict[str, str]
    requestContext: RequestContextT
    body: str
    isBase64Encoded: bool


def parse(data: Mapping[str, Any], keys_and_types: list[tuple[str, Any]]) -> tuple[Any, ...]:
    """
    Convenience function
    """
    result = []
    for key, key_type in keys_and_types:
        if key not in data:
            raise ArgumentError(f"Missing key {key}")
        if not isinstance(data[key], key_type):
            raise ArgumentError(f"Invalid type of key {key}")
        result.append(data[key])
    return tuple(result)


def lambda_handler(event: dict[str, Any], context: LambdaContext) -> dict[str, Any]:  # pylint: disable=unused-argument
    """
    The handler function called by AWS
    """
    logger.info(f"Raw event: {json.dumps(event)}")

    access_control_headers = {
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
    }

    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return {"statusCode": 200, "headers": access_control_headers}

    try:
        if (is_base_64_encoded := event.get("isBase64Encoded")) is not None:
            data = json.loads(base64.b64decode(event.get("body", "")) if is_base_64_encoded else event.get("body", {}))
        else:
            data = event
    except json.decoder.JSONDecodeError as exc:
        return {"statusCode": 400, "body": f"Body is not valid json: {exc}"}

    logger.info(f"Parsed request data: {json.dumps(data)}")

    headers = {"headers": {"Content-Type": "application/json"} | access_control_headers}

    backend = Backend()
    try:
        backend.authenticate(data)
    except ArgumentError as exc:
        return {"statusCode": 400, "body": json.dumps({"error": str(exc)})} | headers

    try:
        action_func = cast(Callable[[dict[str, Any]], dict[str, Any]], getattr(backend, data["action"]))
    except AttributeError as exc:
        return {"statusCode": 400, "body": json.dumps({"error": f"Unknown action {data['action']}"})} | headers

    try:
        response_body = action_func(data)
    except ArgumentError as exc:
        return {"statusCode": 400, "body": json.dumps({"error": str(exc)})} | headers

    return {
        "statusCode": 200,
        "body": json.dumps(response_body),
    } | headers
