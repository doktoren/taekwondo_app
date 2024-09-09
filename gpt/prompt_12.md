Given below is the implementation of an app written in Flutter and a backend written as a Lambda Function.

Analyze it carefully.

I'm like to have the provided dart files documented somehow (don't document the Python file - that's added only for reference)
In Python the standard is to add a triple quoted string in the top of the file - I hope it's similar for dart.

Don't repeat the file content in you output - just the descriptions together with sufficient information on where I should put it.



Content Amazon Lambda Function backend:
```
"""
This python module implements the lambda function that is accessible at
https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/mytest

Testing with `curl -X POST -d <data> -H "Content-type: application/json" <url>`
Url is `'https://r3q25puk2gjbk5oq6ommfbyjye0tnnno.lambda-url.us-east-1.on.aws/'`

Example data, response pairs are shown below.
In every request an action and authentication token must be passed.
The authentication token is only returned by two actions: "admin_create_user" and "admin_retrieve_auth_token".
Every action is refixed with the required role, lower cased, followed by an underscore.

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

This implementation does validation of every request to the endpoint.
However, it assumes that only valid configurations are ever stored in the S3 objects.
"""

import base64
import datetime
import hashlib
import json
import logging
import string
import time
import unicodedata
from copy import deepcopy
from functools import wraps
from random import SystemRandom
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

logger = logging.getLogger()
logger.setLevel(logging.INFO)

RoleT: TypeAlias = Literal["Admin", "Coach", "Student"]
RoleOrAnyT: TypeAlias = Literal["Admin", "Coach", "Student", "Any"]
assert set(get_args(RoleT)) <= set(get_args(RoleOrAnyT))
EpochT = NewType("EpochT", int)
YesNoT: TypeAlias = Literal["Yes", "No"]
YesNoMaybeT: TypeAlias = Literal["Yes", "No", "Maybe"]
SessionStateT: TypeAlias = Literal["archived", "cancelled", "scheduled"]

PUBLIC_BUCKET_NAME: Final = "struer-taekwondo-public"
PRIVATE_BUCKET_NAME: Final = "struer-taekwondo-private"


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


def make_auth_token() -> str:
    """
    Creates a new login token for a user
    """
    return "".join(SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(8))


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
```

Content of ../app/lib/screens/add_training_session_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class AddTrainingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> users;
  final String defaultCoachId;

  const AddTrainingSessionScreen({
    super.key,
    required this.users,
    required this.defaultCoachId,
  });

  @override
  AddTrainingSessionScreenState createState() =>
      AddTrainingSessionScreenState();
}

class AddTrainingSessionScreenState extends State<AddTrainingSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedCoachId;
  String? _comment;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.defaultCoachId;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        _showError('Please select both start and end times.');
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        _showError('End time must be after start time.');
        return;
      }
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;
        final startTime = _startTime!.millisecondsSinceEpoch ~/ 1000;
        final endTime = _endTime!.millisecondsSinceEpoch ~/ 1000;
        final selectedCoachId = _selectedCoachId!;
        final comment = _comment ?? '';

        await ApiService().coachAddTrainingSession(
          authToken,
          startTime,
          endTime,
          selectedCoachId,
          comment,
        );

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getCoachDropdownItems() {
    return widget.users.entries
        .where((entry) =>
    entry.value['role'] == 'Coach' || entry.value['role'] == 'Admin')
        .map((entry) => DropdownMenuItem(
      value: entry.key,
      child: Text(entry.value['name']),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains largely the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Training Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Start Time:'),
              ListTile(
                title: Text(_startTime == null
                    ? 'Select Start Time'
                    : '${_startTime!.year}-${_padZero(_startTime!.month)}-${_padZero(_startTime!.day)} ${_padZero(_startTime!.hour)}:${_padZero(_startTime!.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartTime,
              ),
              const Text('End Time:'),
              ListTile(
                title: Text(_endTime == null
                    ? 'Select End Time'
                    : '${_endTime!.year}-${_padZero(_endTime!.month)}-${_padZero(_endTime!.day)} ${_padZero(_endTime!.hour)}:${_padZero(_endTime!.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndTime,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCoachId,
                decoration: const InputDecoration(labelText: 'Coach'),
                items: _getCoachDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCoachId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a coach.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
                onSaved: (value) {
                  _comment = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // If end time is not set, set it to start time plus 1.5 hours
        _endTime ??= _startTime!.add(const Duration(minutes: 90));
      });
    }
  }

  void _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime ?? (_startTime ?? DateTime.now()),
      firstDate: _startTime ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _endTime ?? (_startTime ?? DateTime.now())),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
```

Content of ../app/lib/screens/admin_tab.dart:
```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ensure this import is present
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import './create_user_screen.dart';
import './update_user_screen.dart';
import '../services/api_service.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({super.key});

  @override
  AdminTabState createState() => AdminTabState();
}

class AdminTabState extends State<AdminTab> {
  void _createUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateUserScreen(),
      ),
    );

    if (result != null && result == true) {
      // DataProvider will notify listeners; no need to refresh manually
    }
  }

  void _updateUser(String userId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserScreen(
          userId: userId,
        ),
      ),
    );

    if (result != null && result == true) {
      // DataProvider will notify listeners; no need to refresh manually
    }
  }

  void _showAuthToken(String userId) async {
    final authToken = await _retrieveAuthToken(userId);
    if (authToken != null) {
      _showAuthTokenDialog(authToken);
    } else {
      _showError('Failed to retrieve auth token.');
    }
  }

  Future<String?> _retrieveAuthToken(String userId) async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authToken = dataProvider.authToken;
      final result = await ApiService().adminShowAuthToken(authToken, userId);
      return result['auth_token'];
    } catch (e) {
      return null;
    }
  }

  void _showAuthTokenDialog(String authToken) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login code'),
        content: SelectableText(authToken),
        actions: [
          TextButton(
            child: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: authToken));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auth token copied to clipboard')),
              );
            },
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final users = dataProvider.userData['users'] as Map<String, dynamic>? ?? {};

    // Sort users by name with explicit types
    final sortedUsers = users.entries.toList()
      ..sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) =>
          (a.value['name'] as String)
              .compareTo(b.value['name'] as String));

    return Column(
      children: [
        ElevatedButton(
          onPressed: _createUser,
          child: const Text('Create User'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedUsers.length,
            itemBuilder: (context, index) {
              final user = sortedUsers[index];
              return ListTile(
                title: Text(user.value['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAuthToken(user.key),
                      child: const Text('Show login'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateUser(user.key),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/screens/coach_tab.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'dart:convert'; // Added
import '../providers/data_provider.dart';
import '../services/api_service.dart';
import './add_training_session_screen.dart';
import './update_training_session_screen.dart';
import './register_participation_screen.dart';
import './participation_history_screen.dart';

class CoachTab extends StatefulWidget {
  const CoachTab({super.key});

  @override
  CoachTabState createState() => CoachTabState();
}

class CoachTabState extends State<CoachTab> {
  final bool _isLoading = false;
  Map<String, bool> _expandedSessions = {};
  bool _allSessionsCollapsed = false; // Added
  static const String _prefsExpandedSessionsKey = 'coach_tab_expanded_sessions';
  static const String _prefsAllSessionsCollapsedKey =
      'coach_tab_all_sessions_collapsed'; // Added

  @override
  void initState() {
    super.initState();
    _loadExpandedSessions();
  }

  Future<void> _loadExpandedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final expandedSessionsString = prefs.getString(_prefsExpandedSessionsKey);
    if (expandedSessionsString != null) {
      _expandedSessions = Map<String, bool>.from(
          jsonDecode(expandedSessionsString) as Map<String, dynamic>);
    }
    _allSessionsCollapsed =
        prefs.getBool(_prefsAllSessionsCollapsedKey) ?? false; // Added
  }

  Future<void> _saveExpandedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsExpandedSessionsKey, jsonEncode(_expandedSessions));
    await prefs.setBool(
        _prefsAllSessionsCollapsedKey, _allSessionsCollapsed); // Added
  }

  void _addTrainingSession() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrainingSessionScreen(
          users: dataProvider.userData['users'] ?? {},
          defaultCoachId: dataProvider.userId,
        ),
      ),
    );

    if (result != null && result == true) {
      // DataProvider will notify listeners; no need to refresh manually
    }
  }

  void _updateSessionState(
      String sessionId, String newState, Map<String, dynamic> session) async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await ApiService().coachUpdateTrainingSessionState(
          dataProvider.authToken, sessionId, newState);
      // After updating the session state, refresh the data
      await dataProvider.refreshData();
      // Since DataProvider notifies listeners, the UI will update automatically
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _confirmDelete(String sessionId, Map<String, dynamic> session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this session? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _updateSessionState(sessionId, 'deleted', session);
    }
  }

  void _registerParticipation(Map<String, dynamic> session) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterParticipationScreen(
          session: session,
          users: dataProvider.userData['users'] ?? {},
          intendedParticipation: session['participation'],
        ),
      ),
    );

    if (result != null && result == true) {
      // DataProvider will notify listeners; no need to refresh manually
    }
  }

  void _updateSession(Map<String, dynamic> session) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTrainingSessionScreen(
          session: session,
          users: dataProvider.userData['users'] ?? {},
        ),
      ),
    );

    if (result != null && result == true) {
      // DataProvider will notify listeners; no need to refresh manually
    }
  }

  void _toggleSessionExpansion(String sessionId) {
    setState(() {
      _expandedSessions[sessionId] = !(_expandedSessions[sessionId] ?? false);

      // Update the _allSessionsCollapsed flag
      final anyExpanded = _expandedSessions.values.any((expanded) => expanded);
      _allSessionsCollapsed = !anyExpanded;

      _saveExpandedSessions();
    });
  }

  void _viewParticipantHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParticipationHistoryScreen(),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<String> _getAllowedStates(String currentState) {
    switch (currentState) {
      case 'scheduled':
        return ['scheduled', 'cancelled', 'deleted'];
      case 'cancelled':
        return ['scheduled', 'cancelled', 'deleted'];
      default:
        return [currentState]; // For 'archived' or other states
    }
  }

  String _formatDateOnly(DateTime dateTime) {
    return '${_getWeekday(dateTime.weekday)} ${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}';
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${_padZero(startTime.hour)}:${_padZero(startTime.minute)} - ${_padZero(endTime.hour)}:${_padZero(endTime.minute)}';
  }

  String _getWeekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  Widget _buildSessionRow(Map<String, dynamic> session, Map<String, dynamic> users,
      String authToken) {
    final sessionId = session['session_id'];
    final coachId = session['coach'];
    final coachName = users[coachId]?['name'] ?? 'Unknown';
    final comment = session['comment'] ?? '';
    final startTime =
    DateTime.fromMillisecondsSinceEpoch(session['start_time'] * 1000);
    final endTime =
    DateTime.fromMillisecondsSinceEpoch(session['end_time'] * 1000);
    final now = DateTime.now();
    final isRegisterable =
        now.isAfter(startTime.subtract(const Duration(minutes: 10))) &&
            session['state'] == "scheduled";
    final isExpanded = _expandedSessions[sessionId] ?? false;

    return Column(
      children: [
        ListTile(
          title: Text(_formatDateOnly(startTime)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRegisterable)
                ElevatedButton(
                  child: const Text('Register P.'),
                  onPressed: () => _registerParticipation(session),
                ),
              if (!isRegisterable && session['state'] == 'scheduled')
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () => _updateSession(session),
                ),
              const SizedBox(width: 8),
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    setState(() {});
                  }
                },
                child: DropdownButton<String>(
                  value: session['state'],
                  items: _getAllowedStates(session['state'])
                      .map((state) => DropdownMenuItem(
                    value: state,
                    child: Text(
                        state[0].toUpperCase() + state.substring(1)),
                  ))
                      .toList(),
                  onChanged: (newState) async {
                    if (newState != null && newState != session['state']) {
                      if (newState == 'deleted') {
                        _confirmDelete(sessionId, session);
                      } else {
                        _updateSessionState(sessionId, newState, session);
                      }
                    }
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                tooltip: 'Details',
                onPressed: () => _toggleSessionExpansion(sessionId),
              ),
            ],
          ),
          onTap: () => _toggleSessionExpansion(sessionId),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session is at ${_formatTimeRange(startTime, endTime)} with $coachName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(comment),
                ],
                const SizedBox(height: 8.0),
                _buildParticipationDetails(session, users),
              ],
            ),
          ),
        if (isExpanded) const Divider(),
      ],
    );
  }

  Widget _buildParticipationDetails(
      Map<String, dynamic> session, Map<String, dynamic> users) {
    final participation = session['participation'] ?? {};
    final yesUsers = <String>[];
    final maybeUsers = <String>[];
    final noUsers = <String>[];

    participation.forEach((userId, status) {
      final userName = users[userId]?['name'] ?? 'Unknown';
      if (status == 'Yes') {
        yesUsers.add(userName);
      } else if (status == 'Maybe') {
        maybeUsers.add(userName);
      } else if (status == 'No') {
        noUsers.add(userName);
      }
    });

    // Helper to build a line with wrapping names
    Widget buildParticipationLine(String label, List<String> names) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                names.isNotEmpty ? names.join(', ') : '',
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildParticipationLine('Yes', yesUsers),
        buildParticipationLine('Maybe', maybeUsers),
        buildParticipationLine('No', noUsers),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final dataProvider = Provider.of<DataProvider>(context);
    final sessionsMap =
        dataProvider.userData['sessions'] as Map<String, dynamic>? ?? {};
    final users = dataProvider.userData['users'] ?? {};
    final authToken = dataProvider.authToken;

    // Convert sessionsMap to a List and ensure the correct type
    final sessions = sessionsMap.values.cast<Map<String, dynamic>>().toList();

    // Sort sessions by 'start_time' in ascending order
    sessions.sort((a, b) =>
        (a['start_time'] as int).compareTo(b['start_time'] as int));

    // Filter out archived sessions older than half a day
    final cutoffTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 43200;
    final filteredSessions = sessions.where((session) {
      if (session['state'] == 'archived' && session['end_time'] < cutoffTime) {
        return false;
      }
      return true;
    }).toList();

    // Check if any of the displayed sessions are expanded
    final anyExpanded = filteredSessions.any(
            (session) => _expandedSessions[session['session_id']] == true);

    // If none of the displayed sessions are expanded and user hasn't collapsed all
    if (filteredSessions.isNotEmpty && !anyExpanded && !_allSessionsCollapsed) {
      final firstSessionId = filteredSessions.first['session_id'] as String;
      _expandedSessions[firstSessionId] = true;
      // No need to call setState() here as build is being called
      _saveExpandedSessions();
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: _addTrainingSession,
          child: const Text('Add Training Session'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSessions.length,
            itemBuilder: (context, index) {
              final session = filteredSessions[index];
              return _buildSessionRow(session, users, authToken);
            },
          ),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: _viewParticipantHistory,
          child: const Text('View participant history'),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/screens/create_user_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  CreateUserScreenState createState() => CreateUserScreenState();
}

class CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _role;
  String? _authToken;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;

        final result = await ApiService().adminCreateUser(
          authToken,
          _name!,
          _role!,
        );
        _authToken = result['auth_token'];

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        _showAuthTokenDialog();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showAuthTokenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Created Successfully'),
        content: SelectableText('Login code: $_authToken'),
        actions: [
          TextButton(
            child: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _authToken!));
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getRoleDropdownItems() {
    return ['Admin', 'Coach', 'Student']
        .map((role) => DropdownMenuItem(
      value: role,
      child: Text(role),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.length < 3 || value.length > 60) {
                    return 'Name must be between 3 and 60 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Role'),
                items: _getRoleDropdownItems(),
                onChanged: (value) {
                  _role = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Content of ../app/lib/screens/home_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import './login_screen.dart';
import './participants_tab.dart';
import './coach_tab.dart';
import './admin_tab.dart';
import './theory_tab.dart';
import './links_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    // Defer the data loading until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.loadUserData();
    if (!mounted) return;
    _setupTabs();
  }

  void _setupTabs() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final role = dataProvider.role;

    _tabs = [
      const ParticipationTab(),
    ];
    if (role == 'Coach' || role == 'Admin') {
      _tabs.add(const CoachTab());
    }
    if (role == 'Admin') {
      _tabs.add(const AdminTab());
    }
    _tabs.add(const TheoryTab());
    _tabs.add(const LinksTab());

    if (_selectedIndex >= _tabs.length) {
      _selectedIndex = 0;
    }

    setState(() {});
  }

  void _refreshData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.refreshData();
    _setupTabs();
  }

  void _logout() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.logout();
    _setupTabs();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    if (dataProvider.isLoading || _tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Struer Taekwondo'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struer Taekwondo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(dataProvider.authToken.isEmpty ? Icons.login : Icons.logout),
            onPressed: () {
              if (dataProvider.authToken.isEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                _logout();
              }
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _getBottomNavBarItems(dataProvider.role),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems(String role) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Participants',
      ),
    ];
    if (role == 'Coach' || role == 'Admin') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Coach',
        ),
      );
    }
    if (role == 'Admin') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Theory',
      ),
    );
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.link),
        label: 'Links',
      ),
    );
    return items;
  }
}
```

Content of ../app/lib/screens/links_tab.dart is not relevant and not shown. It does not depend on any data from the backend.

Content of ../app/lib/screens/login_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();

  void _saveToken() async {
    final token = _tokenController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (!mounted) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.loadUserData();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Login code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveToken,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Content of ../app/lib/screens/participants_tab.dart:
```
import 'dart:convert'; // Added
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class ParticipationTab extends StatefulWidget {
  const ParticipationTab({super.key});

  @override
  ParticipationTabState createState() => ParticipationTabState();
}

class ParticipationTabState extends State<ParticipationTab> {
  Map<String, String> _actingForUsers = {}; // Map of user IDs to auth tokens
  Map<String, bool> _userSelection = {}; // Map to keep track of checkbox states
  String _globalAuthToken = '';
  String _userId = '';
  Map<String, bool> _expandedSessions = {}; // Track expanded sessions
  bool _allSessionsCollapsed = false; // Added
  static const String _prefsExpandedSessionsKey =
      'participants_tab_expanded_sessions';
  static const String _prefsAllSessionsCollapsedKey =
      'participants_tab_all_sessions_collapsed'; // Added

  @override
  void initState() {
    super.initState();
    _loadActingForUsers();
    _loadExpandedSessions();
  }

  Future<void> _loadExpandedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final expandedSessionsString = prefs.getString(_prefsExpandedSessionsKey);
    if (expandedSessionsString != null) {
      _expandedSessions = Map<String, bool>.from(
          jsonDecode(expandedSessionsString) as Map<String, dynamic>);
    }
    _allSessionsCollapsed =
        prefs.getBool(_prefsAllSessionsCollapsedKey) ?? false; // Added
  }

  Future<void> _saveExpandedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsExpandedSessionsKey, jsonEncode(_expandedSessions));
    await prefs.setBool(
        _prefsAllSessionsCollapsedKey, _allSessionsCollapsed); // Added
  }

  void _loadActingForUsers() async {
    final prefs = await SharedPreferences.getInstance();
    _globalAuthToken = prefs.getString('auth_token') ?? '';
    final actingForUsersJson = prefs.getString('acting_for_users');

    if (actingForUsersJson != null && actingForUsersJson.isNotEmpty) {
      _actingForUsers = Map<String, String>.from(jsonDecode(actingForUsersJson));
    } else {
      _actingForUsers = {};
    }
    if (mounted) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      _userId = dataProvider.userId;

      if (_globalAuthToken.isNotEmpty && _userId.isNotEmpty) {
        _actingForUsers[_userId] = _globalAuthToken;
      }
      // Initialize all users as selected (checked)
      _userSelection = {
        for (var userId in _actingForUsers.keys) userId: true,
      };
      setState(() {});
    }
  }

  void _saveActingForUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final actingForUsersJson = jsonEncode(_actingForUsers);
    await prefs.setString('acting_for_users', actingForUsersJson);
  }

  void _toggleSessionExpansion(String sessionId) {
    setState(() {
      _expandedSessions[sessionId] = !(_expandedSessions[sessionId] ?? false);

      // Update the _allSessionsCollapsed flag
      final anyExpanded = _expandedSessions.values.any((expanded) => expanded);
      _allSessionsCollapsed = !anyExpanded;

      _saveExpandedSessions();
    });
  }

  void _addUserById(String userId) async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authToken = dataProvider.authToken;
      final result = await ApiService().adminShowAuthToken(authToken, userId);
      final userAuthToken = result['auth_token'];
      if (!_actingForUsers.containsKey(userId)) {
        setState(() {
          _actingForUsers[userId] = userAuthToken;
          _userSelection[userId] = true; // Initially checked
          _saveActingForUsers();
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to add user: ${e.toString()}');
    }
  }

  void _showAddUserDialog() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userRole = dataProvider.role;

    if (userRole == 'Admin') {
      // Show dialog with dropdown of user names
      String? selectedUserId;
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final users =
                  dataProvider.userData['users'] as Map<String, dynamic>? ?? {};
              // Exclude users already in _actingForUsers
              final availableUsers = users.entries
                  .where((entry) => !_actingForUsers.containsKey(entry.key))
                  .toList();

              return AlertDialog(
                title: const Text('Add User To Register For'),
                content: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select User'),
                  value: selectedUserId,
                  items: availableUsers.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    onPressed: selectedUserId != null
                        ? () {
                      Navigator.pop(context);
                      _addUserById(selectedUserId!);
                    }
                        : null,
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      // Show dialog to enter login code
      showDialog(
        context: context,
        builder: (context) {
          final tokenController = TextEditingController();
          return AlertDialog(
            title: const Text('Add User To Register For'),
            content: TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'Login code',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  final token = tokenController.text.trim();
                  Navigator.pop(context);
                  _addUserByToken(token);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _addUserByToken(String token) async {
    try {
      // Retrieve user data using the provided token
      final userData = await ApiService().studentValidateAuthToken(token);
      if (!mounted) return; // Add this line
      final userId = userData['i_am'];
      if (!_actingForUsers.containsKey(userId)) {
        setState(() {
          _actingForUsers[userId] = token;
          _userSelection[userId] = true; // Initially checked
          _saveActingForUsers();
        });
      }
    } catch (e) {
      if (!mounted) return; // Add this line
      _showError('Failed to add user: ${e.toString()}');
    }
  }

  void _removeUser(String userId) {
    setState(() {
      _actingForUsers.remove(userId);
      _userSelection.remove(userId);
      _saveActingForUsers();
    });
  }

  String _getJoiningStatus(String sessionId, Map<String, dynamic> sessions) {
    final selectedUserIds = _userSelection.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key);
    final session = sessions[sessionId] ?? {};
    final participation = session['participation'] ?? {};
    final statuses = selectedUserIds.map((userId) {
      return participation[userId] ?? 'Unspecified';
    }).toSet();
    if (statuses.isEmpty) return 'Unspecified';
    return statuses.length == 1 ? statuses.first : '-';
  }

  void _updateParticipation(
      String sessionId, String? joining, Map<String, dynamic> sessions) async {
    String? apiJoining =
    (joining == 'Unspecified' || joining == '-') ? null : joining;

    // Collect auth tokens for selected users
    List<String> selectedAuthTokens = [];
    for (var entry in _actingForUsers.entries) {
      final userId = entry.key;
      final authToken = entry.value;
      if (_userSelection[userId] == true) {
        selectedAuthTokens.add(authToken);
      }
    }

    if (selectedAuthTokens.isEmpty) {
      _showError('No users selected to update participation.');
      return;
    }

    try {
      await ApiService()
          .studentRegisterParticipation(selectedAuthTokens, sessionId, apiJoining);

      // Refresh data after updating participation
      if (mounted) {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        await dataProvider.refreshData();
      }
      // The UI will update automatically since DataProvider notifies listeners
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update participation: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(Map<String, dynamic> users) {
    return Column(
      children: [
        ..._actingForUsers.keys.map((userId) {
          final userName = users[userId]?['name'] ?? 'Unknown';
          return CheckboxListTile(
            title: Text(userName),
            value: _userSelection[userId] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _userSelection[userId] = value ?? false;
              });
            },
            secondary: IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () => _removeUser(userId),
            ),
          );
        }),
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Add User To Register For'),
          onPressed: _showAddUserDialog,
        ),
      ],
    );
  }

  String _formatDateOnly(DateTime dateTime) {
    return '${_getWeekday(dateTime.weekday)} ${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}';
  }

  String _formatTimeRange(DateTime startTime, int endTimeEpoch) {
    final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeEpoch * 1000);
    return '${_padZero(startTime.hour)}:${_padZero(startTime.minute)} - ${_padZero(endTime.hour)}:${_padZero(endTime.minute)}';
  }

  String _getWeekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  Widget _buildSessionRow(
      Map<String, dynamic> session, Map<String, dynamic> users) {
    final sessionId = session['session_id'];
    final coachId = session['coach'];
    final coachName = users[coachId]?['name'] ?? 'Unknown';
    final comment = session['comment'] ?? '';
    final startTime =
    DateTime.fromMillisecondsSinceEpoch(session['start_time'] * 1000);
    final joiningStatus = _getJoiningStatus(sessionId, {sessionId: session});
    final isExpanded = _expandedSessions[sessionId] ?? false;

    return Column(
      children: [
        ListTile(
          title: Text(_formatDateOnly(startTime)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: joiningStatus,
                items: ['Yes', 'No', 'Maybe', 'Unspecified', '-']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (session['state'] != 'scheduled')
                    ? null
                    : (value) {
                  if (value != null) {
                    _updateParticipation(
                        sessionId, value, {sessionId: session});
                  }
                },
              ),
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                tooltip: 'Details',
                onPressed: () => _toggleSessionExpansion(sessionId),
              ),
            ],
          ),
          onTap: () => _toggleSessionExpansion(sessionId),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session is at ${_formatTimeRange(startTime, session['end_time'])} with $coachName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(comment),
                ],
                const SizedBox(height: 8.0),
                _buildParticipationDetails(session, users),
              ],
            ),
          ),
        if (isExpanded) const Divider(),
      ],
    );
  }

  Widget _buildParticipationDetails(
      Map<String, dynamic> session, Map<String, dynamic> users) {
    final participation = session['participation'] ?? {};
    final yesUsers = <String>[];
    final maybeUsers = <String>[];
    final noUsers = <String>[];

    participation.forEach((userId, status) {
      final userName = users[userId]?['name'] ?? 'Unknown';
      if (status == 'Yes') {
        yesUsers.add(userName);
      } else if (status == 'Maybe') {
        maybeUsers.add(userName);
      } else if (status == 'No') {
        noUsers.add(userName);
      }
    });

    // Helper to build a line with wrapping names
    Widget buildParticipationLine(String label, List<String> names) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                names.isNotEmpty ? names.join(', ') : '',
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildParticipationLine('Yes', yesUsers),
        buildParticipationLine('Maybe', maybeUsers),
        buildParticipationLine('No', noUsers),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final sessionsMap =
        dataProvider.userData['sessions'] as Map<String, dynamic>? ?? {};
    final users = dataProvider.userData['users'] ?? {};

    // Filter out sessions that are not scheduled
    final activeSessions = sessionsMap.values
        .where((session) => session['state'] == 'scheduled')
        .toList();

    // Sort sessions by 'start_time' in ascending order
    activeSessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));

    // Check if any of the displayed sessions are expanded
    final anyExpanded = activeSessions.any(
            (session) => _expandedSessions[session['session_id']] == true);

    // If none of the displayed sessions are expanded and user hasn't collapsed all
    if (activeSessions.isNotEmpty && !anyExpanded && !_allSessionsCollapsed) {
      final firstSessionId = activeSessions.first['session_id'] as String;
      _expandedSessions[firstSessionId] = true;
      // No need to call setState() here as build is being called
      _saveExpandedSessions();
    }

    return Column(
      children: [
        // Display the list of users you're acting for dynamically sized
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildUserList(users),
        ),
        const Divider(),
        // Display the list of sessions
        Expanded(
          child: ListView.builder(
            itemCount: activeSessions.length,
            itemBuilder: (context, index) {
              final session = activeSessions[index];
              return _buildSessionRow(session, users);
            },
          ),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/screens/participation_history_screen.dart:
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class ParticipationHistoryScreen extends StatefulWidget {
  const ParticipationHistoryScreen({super.key});

  @override
  ParticipationHistoryScreenState createState() =>
      ParticipationHistoryScreenState();
}

class ParticipationHistoryScreenState
    extends State<ParticipationHistoryScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  final List<bool> _weekDaysSelected = List<bool>.filled(7, true);
  Map<String, dynamic> _historyData = {};
  List<DateTime> _filteredDates = [];
  List<String> _participantIds = [];
  Map<String, Map<String, bool>> _participationMatrix = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      int startTime = _startDate.millisecondsSinceEpoch ~/ 1000;
      int endTime =
          (_endDate.add(const Duration(days: 1))).millisecondsSinceEpoch ~/
              1000;
      final data = await ApiService().coachGetHistoricalParticipation(
        dataProvider.authToken,
        startTime,
        endTime,
      );
      _historyData = data;
      _processData(_historyData);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processData(Map<String, dynamic> data) {
    // Build a list of dates and participation
    _filteredDates = [];
    _participantIds = [];
    _participationMatrix = {};

    // Filter dates by selected weekdays
    Set<int> selectedWeekDays = {};
    for (int i = 0; i < 7; i++) {
      if (_weekDaysSelected[i]) {
        selectedWeekDays.add(i + 1); // DateTime weekday is 1-7 (Mon-Sun)
      }
    }

    // Collect all participant IDs who have participated
    Set<String> participantIdsSet = {};

    // Build list of dates and participation
    data.forEach((sessionId, sessionData) {
      Map<String, dynamic> session = sessionData['session'];
      List<dynamic> participants = sessionData['participants'];

      DateTime date = DateTime.fromMillisecondsSinceEpoch(session['start_time'] * 1000);
      if (!selectedWeekDays.contains(date.weekday)) return;

      String dateKey = _formatDateOnly(date);
      _filteredDates.add(date);
      _participationMatrix[dateKey] = {};

      for (String participantId in participants) {
        _participationMatrix[dateKey]![participantId] = true;
        participantIdsSet.add(participantId);
      }
    });

    // Remove duplicate dates and sort
    _filteredDates = _filteredDates.toSet().toList();
    _filteredDates.sort();

    _participantIds = participantIdsSet.toList();

    // Remove users who have not participated in any session
    _participantIds = _participantIds.where((participantId) {
      return _participationMatrix.values.any((dateMap) => dateMap[participantId] == true);
    }).toList();

    // Sort participants by name
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final users = dataProvider.userData['users'] ?? {};
    _participantIds.sort((a, b) => (users[a]?['name'] ?? '').compareTo(users[b]?['name'] ?? ''));

    setState(() {});
  }

  void _toggleWeekDay(int index) {
    setState(() {
      _weekDaysSelected[index] = !_weekDaysSelected[index];
      if (_historyData.isNotEmpty) {
        _processData(_historyData);
      }
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _formatDateOnly(DateTime dateTime) {
    String weekDay = _getWeekday(dateTime.weekday);
    String year = dateTime.year.toString();
    String month = _padZero(dateTime.month);
    String day = _padZero(dateTime.day);
    return '$weekDay $year-$month-$day';
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (date != null) {
      setState(() {
        _startDate = DateTime(date.year, date.month, date.day);
        if (_historyData.isNotEmpty) {
          _processData(_historyData);
        }
      });
    }
  }

  void _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = DateTime(date.year, date.month, date.day);
        if (_historyData.isNotEmpty) {
          _processData(_historyData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final users = dataProvider.userData['users'] ?? {};

    List<Widget> weekDayCheckboxes = List<Widget>.generate(7, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getWeekday(index + 1)),
            Checkbox(
              value: _weekDaysSelected[index],
              onChanged: (value) {
                _toggleWeekDay(index);
              },
            ),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participation History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                        'Start Date: ${_startDate.year}-${_padZero(_startDate.month)}-${_padZero(_startDate.day)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickStartDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                        'End Date: ${_endDate.year}-${_padZero(_endDate.month)}-${_padZero(_endDate.day)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickEndDate,
                  ),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text('Filtering:'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: weekDayCheckboxes,
            ),
            const SizedBox(height: 16.0),
            _buildParticipationMatrix(users),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationMatrix(Map<String, dynamic> users) {
    if (_participationMatrix.isEmpty) {
      return const Center(child: Text('No data'));
    }

    List<TableRow> rows = [];

    // Build header row with participant names written vertically
    List<Widget> headerCells = [
      const SizedBox(
        width: 100,
      ), // Empty top-left cell
    ];
    for (String participantId in _participantIds) {
      String name = users[participantId]?['name'] ?? 'Unknown';
      headerCells.add(
        Container(
          padding: const EdgeInsets.all(4.0),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              name,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      );
    }
    rows.add(TableRow(children: headerCells));

    // Build data rows
    for (DateTime date in _filteredDates) {
      String dateKey = _formatDateOnly(date);
      List<Widget> cells = [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            dateKey,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 14.0),
          ),
        ),
      ];
      for (String participantId in _participantIds) {
        bool participated = _participationMatrix[dateKey]?[participantId] ?? false;
        cells.add(
          Center(child: Text(participated ? 'X' : '')),
        );
      }
      rows.add(TableRow(children: cells));
    }

    // Build total row
    List<Widget> totalCells = [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: const Text(
          'Total',
          style: TextStyle(fontFamily: 'Courier', fontSize: 14.0),
        ),
      ),
    ];
    for (String participantId in _participantIds) {
      int total = 0;
      _participationMatrix.forEach((dateKey, participantMap) {
        if (participantMap[participantId] == true) {
          total++;
        }
      });
      totalCells.add(
        Center(child: Text('$total')),
      );
    }
    rows.add(TableRow(children: totalCells));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: rows,
      ),
    );
  }
}
```

Content of ../app/lib/screens/register_participation_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class RegisterParticipationScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> users;
  final Map<String, dynamic>? intendedParticipation;

  const RegisterParticipationScreen({
    super.key,
    required this.session,
    required this.users,
    this.intendedParticipation,
  });

  @override
  RegisterParticipationScreenState createState() =>
      RegisterParticipationScreenState();
}

class RegisterParticipationScreenState
    extends State<RegisterParticipationScreen> {
  List<String> _selectedParticipants = [];
  List<Map<String, dynamic>> _sortedUsers = [];

  @override
  void initState() {
    super.initState();
    _sortUsers();
  }

  void _sortUsers() {
    final yesUsers = <Map<String, dynamic>>[];
    final maybeUsers = <Map<String, dynamic>>[];
    final otherUsers = <Map<String, dynamic>>[];

    widget.users.forEach((userId, user) {
      final participation = widget.intendedParticipation?[userId];
      final userInfo = {'userId': userId, 'name': user['name']};

      if (participation == 'Yes') {
        yesUsers.add(userInfo);
      } else if (participation == 'Maybe') {
        maybeUsers.add(userInfo);
      } else {
        otherUsers.add(userInfo);
      }
    });

    // Sort each list by name
    yesUsers.sort((a, b) => a['name'].compareTo(b['name']));
    maybeUsers.sort((a, b) => a['name'].compareTo(b['name']));
    otherUsers.sort((a, b) => a['name'].compareTo(b['name']));

    setState(() {
      _sortedUsers = [
        ...yesUsers,
        ...maybeUsers,
        ...otherUsers,
      ];

      // Initialize _selectedParticipants with 'Yes' and 'Maybe' users
      _selectedParticipants = [
        ...yesUsers.map((user) => user['userId']),
        ...maybeUsers.map((user) => user['userId']),
      ];
    });
  }

  void _submit() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authToken = dataProvider.authToken;

      await ApiService().coachRegisterParticipation(
          authToken, widget.session['session_id'], _selectedParticipants);

      // Refresh data in the DataProvider
      await dataProvider.refreshData();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _toggleParticipant(String userId) {
    setState(() {
      if (_selectedParticipants.contains(userId)) {
        _selectedParticipants.remove(userId);
      } else {
        _selectedParticipants.add(userId);
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userId = user['userId'];
    final isSelected = _selectedParticipants.contains(userId);
    return ListTile(
      title: Text(user['name']),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => _toggleParticipant(userId),
      ),
      onTap: () => _toggleParticipant(userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Participation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _sortedUsers.map(_buildUserTile).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

Content of ../app/lib/screens/theory_data.dart is not relevant and not shown. It does not depend on any data from the backend.

Content of ../app/lib/screens/theory_data_example.dart:
```
// theory_data.dart

class Belt {
  final int level;
  final String name;
  final Map<String, Map<String, String>> categories;

  Belt({required this.level, required this.name, required this.categories});
}

final List<Belt> allBelts = [
  Belt(
    level: 10,
    name: '10. kup - hvidt bælte med gul streg',
    categories: {
      'Stand': {
        'Moa-seogi': 'Samlet fødder stand (hilsestand)',
        'Dwichook-moa-seogi': 'Stand med samlede hæle (Knyttet håndsbredde mellem tæer)',
        'Naranhi-seogi': 'Parallel stand (skulderstandsbredde mellem fødderne)',
        'Joochoom-seogi': 'Hestestand (1½ skulderbredde mellem fødderne)',
      },
      'Håndteknik': {
        'Eolgul jireugi': 'Slag høj sektion. (Hånden i næsehøjde)',
        'Momtong jireugi': 'Slag midter sektion (Hånden ud for solar plexus)',
        'Arae jireugi': 'Slag lav sektion (Hånd mellem navle og skamben.)',
      },
      'Benteknik': {
        'Bakat-chagi': 'Udadgående spark (Rammer med knivfod)',
        'An-chagi': 'Indadgående spark (Rammer med flad fod)',
        'Ap-chagi': 'Front spark (Rammer med apchook)',
      },
      'Teori': {
        'Jumeok': 'Knyttet hånd',
        'Jireugi': 'Slag fra hoften m. knyttet hånd',
        'Chagi': 'Spark',
        'Ap': 'Front',
      },
    },
  ),
  Belt(
    level: 9,
    name: '9. kup - gult bælte',
    // More entries of the same kind ...
    categories: {
      // Similar to categories in the entry above
    },
  ),
  // More entries of the same kind ...
];
```

Content of ../app/lib/screens/theory_tab.dart is not relevant and not shown. It does not depend on any data from the backend.

Content of ../app/lib/screens/update_training_session_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class UpdateTrainingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> users;

  const UpdateTrainingSessionScreen({
    super.key,
    required this.session,
    required this.users,
  });

  @override
  UpdateTrainingSessionScreenState createState() =>
      UpdateTrainingSessionScreenState();
}

class UpdateTrainingSessionScreenState
    extends State<UpdateTrainingSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;
  String? _selectedCoachId;
  String? _comment;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.session['coach'];
    _comment = widget.session['comment'];
    _startTime =
        DateTime.fromMillisecondsSinceEpoch(widget.session['start_time'] * 1000);
    _endTime =
        DateTime.fromMillisecondsSinceEpoch(widget.session['end_time'] * 1000);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_endTime.isBefore(_startTime)) {
        _showError('End time must be after start time.');
        return;
      }
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;
        final startTime = _startTime.millisecondsSinceEpoch ~/ 1000;
        final endTime = _endTime.millisecondsSinceEpoch ~/ 1000;
        final selectedCoachId = _selectedCoachId!;
        final comment = _comment ?? '';

        await ApiService().coachUpdateTrainingSession(
          authToken,
          widget.session['session_id'],
          startTime,
          endTime,
          selectedCoachId,
          comment,
        );

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getCoachDropdownItems() {
    return widget.users.entries
        .where((entry) =>
    entry.value['role'] == 'Coach' || entry.value['role'] == 'Admin')
        .map((entry) => DropdownMenuItem(
      value: entry.key,
      child: Text(entry.value['name']),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains largely the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Training Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Start Time:'),
              ListTile(
                title: Text(
                    '${_startTime.year}-${_padZero(_startTime.month)}-${_padZero(_startTime.day)} ${_padZero(_startTime.hour)}:${_padZero(_startTime.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartTime,
              ),
              const Text('End Time:'),
              ListTile(
                title: Text(
                    '${_endTime.year}-${_padZero(_endTime.month)}-${_padZero(_endTime.day)} ${_endTime.hour}:${_padZero(_endTime.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndTime,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCoachId,
                decoration: const InputDecoration(labelText: 'Coach'),
                items: _getCoachDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCoachId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a coach.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _comment,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
                onSaved: (value) {
                  _comment = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // If end time is not set, set it to start time plus 1.5 hours
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(minutes: 90));
        }
      });
    }
  }

  void _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: _startTime,
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
```

Content of ../app/lib/screens/update_user_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

class UpdateUserScreen extends StatefulWidget {
  final String userId;

  const UpdateUserScreen({
    super.key,
    required this.userId,
  });

  @override
  UpdateUserScreenState createState() => UpdateUserScreenState();
}

class UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _role;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = dataProvider.userData['users'][widget.userId];
      if (user != null) {
        setState(() {
          _name = user['name'];
          _role = user['role'];
          _isLoading = false;
        });
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;

        await ApiService().adminUpdateUser(
          authToken,
          widget.userId,
          _name!,
          _role!,
        );

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm == true) {
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;

        await ApiService().adminDeleteUser(authToken, widget.userId);

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getRoleDropdownItems() {
    return ['Admin', 'Coach', 'Student']
        .map((role) => DropdownMenuItem(
      value: role,
      child: Text(role),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading indicator while fetching user data
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update User'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.length < 3 || value.length > 60) {
                    return 'Name must be between 3 and 60 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _getRoleDropdownItems(),
                onChanged: (value) {
                  _role = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update User'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Content of ../app/lib/services/api_service.dart:
```
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ApiService {
  final String _baseUrl =
      'https://nxs7ohc4iutdnwp2u45xbphxly0murpo.lambda-url.eu-central-1.on.aws/';

  Future<dynamic> _post(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'An error occurred');
    }
  }

  Future<Map<String, dynamic>> anonymousShowInfo() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
        'https://struer-taekwondo-public.s3.eu-central-1.amazonaws.com/data.json?t=$timestamp');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> studentRegisterParticipation(
      List<String> authTokens, String sessionId, String? joining) async {
    await _post({
      'action': 'any_register_participation',
      'joining_sessions': {sessionId: joining},
      'user_auth_tokens': authTokens,
    });
  }

  Future<Map<String, dynamic>> adminCreateUser(
      String authToken, String name, String role) async {
    return await _post({
      'action': 'admin_create_user',
      'auth_token': authToken,
      'name': name,
      'role': role,
    });
  }

  Future<void> adminUpdateUser(
      String authToken, String userId, String name, String role) async {
    await _post({
      'action': 'admin_update_user',
      'auth_token': authToken,
      'user_id': userId,
      'name': name,
      'role': role,
    });
  }

  Future<void> adminDeleteUser(String authToken, String userId) async {
    await _post({
      'action': 'admin_delete_user',
      'auth_token': authToken,
      'user_id': userId,
    });
  }

  Future<Map<String, dynamic>> adminShowAuthToken(
      String authToken, String userId) async {
    return await _post({
      'action': 'admin_show_auth_token',
      'auth_token': authToken,
      'user_id': userId,
    });
  }

  Future<Map<String, dynamic>> coachAddTrainingSession(
      String authToken,
      int startTime,
      int endTime,
      String coachId,
      String comment) async {
    return await _post({
      'action': 'coach_add_training_session',
      'auth_token': authToken,
      'start_time': startTime,
      'end_time': endTime,
      'coach': coachId,
      'comment': comment,
    });
  }

  Future<void> coachUpdateTrainingSessionState(
      String authToken, String sessionId, String state) async {
    await _post({
      'action': 'coach_update_training_session',
      'auth_token': authToken,
      'session_id': sessionId,
      'session_state': state,
    });
  }

  Future<void> coachUpdateTrainingSession(
      String authToken,
      String sessionId,
      int startTime,
      int endTime,
      String coachId,
      String comment) async {
    await _post({
      'action': 'coach_update_training_session',
      'auth_token': authToken,
      'session_id': sessionId,
      'start_time': startTime,
      'end_time': endTime,
      'coach': coachId,
      'comment': comment,
    });
  }

  Future<void> coachRegisterParticipation(
      String authToken, String sessionId, List<String> participants) async {
    await _post({
      'action': 'coach_register_participation',
      'auth_token': authToken,
      'session_id': sessionId,
      'participants': participants,
    });
  }

  Future<Map<String, dynamic>> coachGetHistoricalParticipation(
      String authToken, int startTime, int endTime) async {
    return await _post({
      'action': 'coach_get_historical_participation',
      'auth_token': authToken,
      'start_time': startTime,
      'end_time': endTime,
    });
  }

  String _hashToken(String token) {
    var bytes = utf8.encode(token);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> studentValidateAuthToken(String authToken) async {
    final data = await anonymousShowInfo();
    final authTokenHashed = _hashToken(authToken);

    final users = data['users'] as Map<String, dynamic>;
    for (final userId in users.keys) {
      if (users[userId]['auth_token'] == authTokenHashed &&
          users[userId]['auth_token'] != null) {
        data['i_am'] = userId;
        return data;
      }
    }

    throw Exception('Auth token is invalid');
  }
}
```

Content of ../app/lib/main.dart:
```
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAuthToken();
  runApp(const StruerTKDApp());
}

Future<void> _initializeAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('auth_token') == null) {
    await prefs.setString('auth_token', '');
  }
}

class StruerTKDApp extends StatelessWidget {
  const StruerTKDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataProvider>(
      create: (_) => DataProvider(),
      child: MaterialApp(
        title: 'Struer Taekwondo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

