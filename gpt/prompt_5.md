Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

I'd like you to make a bunch of changes to improve the user interface.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.
Also, remember to let me know if an existing file is no longer needed.

### The participants tab

The horizontal line between each session should be removed. It should still be shown below a session that has been expanded though (below the first section or below a section where one has clicked "See participation"). The "See participation" text should be replaced with "Details".

Change the listing such that both the time of the day, the "Coach: <name>" and the session comment is only shown for an expanded session.

The text for an unexpanded session should then be on the format "Tuesday 2024-10-29" while the additional text for an expanded session should be on the format shown below

```
Session is at 19:00 - 20:30 with Minik
<Extra line or lines with comment, no empty line if comment is empty>
Yes: Jesper Barrith
Maybe: 
No: Jesper TK, Minik
```


### The coach tab

In the "Add Training Session" tab I'd like to change how the start and end time is specified.
If possible, I prefer a 24 hour clock where you don't need to switch between am and pm.
For the choice of start time: If possible, I prefer that HH:MM is set to 19:00 by default after having chosen the date.
If the user first selects start time and end time has not yet been specified, then set end time to start time plus 1 1/2 hour.

The session listing should be changed to show the same information as on the participants page.
So here most information should also be hidden by default (expect for the first session) and be unfolded by clicking the "details" icon.

Add a filtering such that archived sessions older than half a day are not shown.

The "Register P." button should not be shown instead of the session state dropdown; it should be shown in addition to the session state dropdown - immediately before it.

I've updated the backend such that the action `coach_update_training_session` now recognized two different sets of arguments.
The new set of arguments is for updating a session without changing its state.
For a scheduled session where the button "Register P." is NOT shown (that is; a more future session) there should instead be a button with the text "Update". Clicking this button should bring you to a new screen similar to when you click "Add Training Session". When clicking "Update" or "Submit" (what you find most appropriate) this should trigger that `coach_update_training_session` is called with the new set of arguments - via a new function in `api_service.dart`


## The admin tab

The admin tab should be almost redone from scratch.

In the top there should still be the button "Create User" but it should no longer be stretched in size.

The two other buttons should be removed.

Below the "Create User" button there should be a listing of all users, sorted in alphabetic order according to name.

Each line should contain the user name, left aligned followed by 2 buttons: "Show login" and "Update". These buttons should be right aligned.

"Show login" behave like the old "Retrieve Auth Token" button.

"Update" should show a new screen similar to "Create User". This screen should also include a button for deleting the user.
When clicking this button the UI should ask for confirmation.

Note that the button "Update" requires a new method in `api_service.dart` to be added - calling the action `admin_update_user`.



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
    barrith_admin_id = make_id()
    jesper_admin_id = make_id()
    minik_coach_id = make_id()
    misha_student_id = make_id()

    session_1_id = make_id()
    session_2_id = make_id()

    time_now = time.time()
    session_1_start_time = 1727370000
    while session_1_start_time < time_now:
        session_1_start_time += 604800
    session_2_start_time = 1727802000
    while session_2_start_time < time_now:
        session_2_start_time += 604800

    return Data(
        users={
            barrith_admin_id: User(
                user_id=barrith_admin_id,
                role="Admin",
                name="Jesper Barrith",
                auth_token=make_auth_token(),
            ),
            jesper_admin_id: User(
                user_id=jesper_admin_id,
                role="Admin",
                name="Jesper TK (Admin)",
                auth_token=make_auth_token(),
            ),
            jesper_admin_id: User(
                user_id=jesper_admin_id,
                role="Student",
                name="Jesper TK",
                auth_token=make_auth_token(),
            ),
            minik_coach_id: User(
                user_id=minik_coach_id,
                role="Coach",
                name="Minik",
                auth_token=make_auth_token(),
            ),
            misha_student_id: User(
                user_id=misha_student_id,
                role="Student",
                name="Misha",
                auth_token=make_auth_token(),
            ),
        },
        sessions={
            session_1_id: TrainingSession(
                session_id=session_1_id,
                start_time=EpochT(session_1_start_time),
                end_time=EpochT(session_1_start_time + 5400),
                coach=minik_coach_id,
                state="scheduled",
                participation={
                    barrith_admin_id: "Yes",
                    jesper_admin_id: "Yes",
                    minik_coach_id: "Yes",
                    misha_student_id: "No",
                },
            ),
            session_2_id: TrainingSession(
                session_id=session_2_id,
                start_time=EpochT(session_2_start_time),
                end_time=EpochT(session_2_start_time + 5400),
                coach=barrith_admin_id,
                state="scheduled",
                participation={
                    barrith_admin_id: "Yes",
                    jesper_admin_id: "Yes",
                    minik_coach_id: "Maybe",
                    misha_student_id: "Yes",
                },
            ),
        },
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
        self._filter_old_data()
        self._write_to_private_s3(
            data=self._data,
            key="data.json",
        )
        self._write_to_public_s3(
            data=self._data
            | {
                "users": {
                    user_id: user | {"auth_token": hash_token(user["auth_token"])}
                    for user_id, user in self._data["users"].items()
                }
            },
            key="data.json",
        )

    def _filter_old_data(self) -> None:
        """
        Remove old data from self._data
        """
        time_now = time.time()
        for session_id, session in self._data["sessions"].items():
            if session["state"] == "archived" and session["end_time"] + 43200 < time_now:
                self._data["sessions"].pop(session_id)

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
        if not 3 <= len(name) <= 60:
            raise ArgumentError("Name must have length in [3..60]")
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
        if self._data["users"].pop(user_id, None) is None:
            raise ArgumentError(f"User with id {user_id} not found")
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

        participants.sort()
        participation = Participation(
            session=session,
            participants=participants,
        )
        yyyymmdd = datetime.datetime.fromtimestamp(session["start_time"], datetime.timezone.utc).strftime("%Y%m%d")
        self._write_to_private_s3(data=participation, key=f"sessions/{yyyymmdd}/{session_id}")

        self._data["sessions"][session_id]["state"] = "archived"
        self._save_data()
        return {}


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
import '../services/api_service.dart';

class AddTrainingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> users;
  final String defaultCoachId;
  final String authToken;

  const AddTrainingSessionScreen({super.key,
    required this.users,
    required this.defaultCoachId,
    required this.authToken,
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
        _showError('Please select start and end times.');
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        _showError('End time must be after start time.');
        return;
      }
      _formKey.currentState!.save();
      try {
        final authToken = widget.authToken;
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

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _showError(e.toString());
      }
    }
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
                    : _startTime.toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartTime,
              ),
              const Text('End Time:'),
              ListTile(
                title: Text(_endTime == null
                    ? 'Select End Time'
                    : _endTime.toString()),
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
        initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
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
}
```

Content of ../app/lib/screens/admin_tab.dart:
```
import 'package:flutter/material.dart';
import './create_user_screen.dart';
import './delete_user_screen.dart';
import './show_auth_token_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminTab extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminTab({super.key, required this.userData});

  @override
  AdminTabState createState() => AdminTabState();
}

class AdminTabState extends State<AdminTab> {
  String _authToken = '';
  late Map<String, dynamic> _users;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _users = widget.userData['users'];
  }

  void _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';
  }

  void _createUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(authToken: _authToken),
      ),
    );

    if (result != null && result == true) {
      // Refresh data if needed
    }
  }

  void _deleteUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteUserScreen(
          authToken: _authToken,
          users: _users,
        ),
      ),
    );

    if (result != null && result == true) {
      // Refresh data if needed
    }
  }

  void _showAuthToken() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowAuthTokenScreen(
          authToken: _authToken,
          users: _users,
        ),
      ),
    );

    if (result != null && result == true) {
      // Handle if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ElevatedButton(
          onPressed: _createUser,
          child: Text('Create User'),
        ),
        ElevatedButton(
          onPressed: _deleteUser,
          child: Text('Delete User'),
        ),
        ElevatedButton(
          onPressed: _showAuthToken,
          child: Text('Show Authentication Token for User'),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/screens/coach_tab.dart:
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './add_training_session_screen.dart';
import './register_participation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachTab extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CoachTab({super.key, required this.userData});

  @override
  CoachTabState createState() => CoachTabState();
}

class CoachTabState extends State<CoachTab> {
  late List<dynamic> _sessions;
  late Map<String, dynamic> _users;
  String _authToken = '';
  String _userId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sessions = widget.userData['sessions'].values.toList();
    _users = widget.userData['users'];
    _userId = widget.userData['i_am'];
    _loadAuthToken();
    // Sort sessions by 'start_time' in ascending order
    _sessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));
  }

  void _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';
  }

  void _addTrainingSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrainingSessionScreen(
          users: _users,
          defaultCoachId: _userId,
          authToken: _authToken,
        ),
      ),
    );

    if (result != null && result == true) {
      // Refresh data
      setState(() {
        _isLoading = true;
      });
      _refreshData();
    }
  }

  void _refreshData() async {
    try {
      final data = await ApiService().anonymousShowInfo();
      setState(() {
        _sessions = data['sessions'].values.toList();
        _users = data['users'];
        _isLoading = false;
      });
      // Sort sessions by 'start_time' in ascending order
      _sessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateSessionState(String sessionId, String newState, Map<String, dynamic> session) async {
    try {
      await ApiService().coachUpdateTrainingSession(_authToken, sessionId, newState);
      if (newState == 'deleted') {
        setState(() {
          _sessions.removeWhere((s) => s['session_id'] == sessionId);
        });
      } else {
        final index = _sessions.indexWhere((s) => s['session_id'] == sessionId);
        if (index != -1) {
          setState(() {
            _sessions[index]['state'] = newState;
          });
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _confirmDelete(String sessionId, Map<String, dynamic> session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
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
    } else {
      // Revert selection to previous state
      setState(() {
        session['state'] = session['state'];
      });
    }
  }

  void _registerParticipation(Map<String, dynamic> session) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterParticipationScreen(
          session: session,
          users: _users,
          intendedParticipation: session['participation'],
          authToken: _authToken,
        ),
      ),
    );

    if (result != null && result == true) {
      // Refresh data to update the state and show session as archived
      _refreshData();
    }
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

  Widget _buildSessionRow(Map<String, dynamic> session) {
    final sessionId = session['session_id'];
    final coachId = session['coach'];
    final coachName = _users[coachId]?['name'] ?? 'Unknown';
    final comment = session['comment'] ?? '';
    final startTime = DateTime.fromMillisecondsSinceEpoch(
        session['start_time'] * 1000);
    final now = DateTime.now();
    final isRegisterable = now.isAfter(startTime.subtract(const Duration(minutes: 10))) &&
          session['state'] == "scheduled";

    return ListTile(
      title: Text(
        _formatDateTime(startTime),
      ),
      subtitle: Text(
        'Coach: $coachName\n$comment',
      ),
      trailing: isRegisterable
        ? ElevatedButton(
            child: const Text('Register P.'),
            onPressed: () => _registerParticipation(session),
          )
        : Focus(
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
                        child: Text(state[0].toUpperCase() + state.substring(1)),
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
                // Unfocus to remove the highlight
                FocusScope.of(context).unfocus();
              },
            ),
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getWeekday(dateTime.weekday)} ${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addTrainingSession,
          child: const Text('Add Training Session'),
        ),
        Expanded(
          child: ListView(
            children: _sessions.map((session) => _buildSessionRow(session)).toList(),
          ),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/screens/create_user_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package
import '../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  final String authToken;

  const CreateUserScreen({super.key, required this.authToken});

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
        final result = await ApiService().adminCreateUser(
          widget.authToken,
          _name!,
          _role!,
        );
        _authToken = result['auth_token'];
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
        title: Text('User Created Successfully'),
        content: SelectableText('Authentication Token: $_authToken'),
        actions: [
          TextButton(
            child: Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _authToken!)); // Copy to clipboard
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close'),
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

Content of ../app/lib/screens/delete_user_screen.dart:
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeleteUserScreen extends StatefulWidget {
  final String authToken;
  final Map<String, dynamic> users;

  const DeleteUserScreen({super.key, required this.authToken, required this.users});

  @override
  DeleteUserScreenState createState() => DeleteUserScreenState();
}

class DeleteUserScreenState extends State<DeleteUserScreen> {
  String? _selectedUserId;

  void _deleteUser() async {
    if (_selectedUserId == null) {
      _showError('Please select a user to delete.');
      return;
    }
    try {
      await ApiService()
          .adminDeleteUser(widget.authToken, _selectedUserId!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    }
  }

  List<DropdownMenuItem<String>> _getUserDropdownItems() {
    return widget.users.entries
        .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value['name']),
            ))
        .toList();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'User'),
              items: _getUserDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a user.';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteUser,
              child: Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Content of ../app/lib/screens/home_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './admin_tab.dart';
import './coach_tab.dart';
import './participants_tab.dart';
import './login_screen.dart';
import './links_tab.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _role = '';
  int _selectedIndex = 0;
  List<Widget> _tabs = [];
  bool _isLoading = true;
  String _authToken = '';
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<String?> _getUserIdFromToken(String authToken) async {
    try {
      final userData = await ApiService().studentValidateAuthToken(authToken);
      return userData['i_am'];
    } catch (e) {
      return null;
    }
  }

  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';

    try {
      final data = await ApiService().anonymousShowInfo();
      _userData = data;
      final userId = await _getUserIdFromToken(_authToken);
      if (userId != null) {
        final users = data['users'] as Map<String, dynamic>;
        final user = users[userId];
        _role = user['role'];
        _userData['i_am'] = userId;
      } else {
        _role = 'Anonymous';
      }
      _setupTabs();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupTabs() {
    _tabs = [
      ParticipationTab(userData: _userData),
    ];
    if (_role == 'Coach' || _role == 'Admin') {
      _tabs.add(CoachTab(userData: _userData));
    }
    if (_role == 'Admin') {
      _tabs.add(AdminTab(userData: _userData));
    }
    _tabs.add(LinksTab());
    // Ensure that selectedIndex is within the bounds of _tabs
    if (_selectedIndex >= _tabs.length) {
      _selectedIndex = 0;
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    _loadUserRole();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    setState(() {
      _authToken = '';
      _role = 'Anonymous';
      _setupTabs();
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.pop(context);
              if (message.contains('Authentication token not provided')) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Struer Taekwondo App v0.2'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Struer Taekwondo App v0.2'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(_authToken.isEmpty ? Icons.login : Icons.logout),
            onPressed: () {
              if (_authToken.isEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
        items: _getBottomNavBarItems(),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue, // Set your desired selected item color
        unselectedItemColor: Colors.grey, // Set your desired unselected item color
        backgroundColor: Colors.white, // Set the background color
        type: BottomNavigationBarType.fixed, // Ensure all items are displayed
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Participants',
      ),
    ];
    if (_role == 'Coach' || _role == 'Admin') {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Coach',
        ),
      );
    }
    if (_role == 'Admin') {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    items.add(
      BottomNavigationBarItem(
        icon: Icon(Icons.link),
        label: 'Links',
      )
    );
    return items;
  }
}
```

Content of ../app/lib/screens/links_tab.dart:
```
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksTab extends StatelessWidget {
  const LinksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: Text('Struer Taekwondo\'s hjemmeside'),
          onTap: () => _launchURL(Uri.https('struertkd.dk')),
        ),
        ListTile(
          title: Text('Facebook'),
          onTap: () => _launchURL(Uri.https('www.facebook.com', '/groups/33971838859')),
        ),
        ListTile(
          title: Text('TikTok'),
          onTap: () => _launchURL(Uri.https('www.tiktok.com', '/@struer.taekwondo')),
        ),
      ],
    );
  }

  void _launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
```

Content of ../app/lib/screens/login_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home_screen.dart';

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
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
        title: Text('Enter Authentication Token\n(Leave blank for anonymous)'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Authentication Token',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveToken,
              child: Text('Continue'),
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
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ParticipationTab extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ParticipationTab({super.key, required this.userData});

  @override
  ParticipationTabState createState() => ParticipationTabState();
}

class ParticipationTabState extends State<ParticipationTab> {
  late Map<String, dynamic> _sessions;
  late Map<String, dynamic> _users;
  Map<String, String> _actingForUsers = {}; // Map of user IDs to auth tokens
  Map<String, bool> _userSelection = {}; // Map to keep track of checkbox states
  String _globalAuthToken = '';
  String _userId = '';
  final Map<String, bool> _expandedSessions = {}; // Track expanded sessions

  @override
  void initState() {
    super.initState();
    _sessions = widget.userData['sessions'] as Map<String, dynamic>;
    _users = widget.userData['users'];
    _userId = widget.userData['i_am'] ?? '';
    _loadActingForUsers();
    // Expand the participation section by default for the first session
    final activeSessions = _sessions.values
        .where((session) => session['state'] == 'scheduled')
        .toList();
    if (activeSessions.isNotEmpty) {
      // Sort sessions by 'start_time' in ascending order
      activeSessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));
      final firstSessionId = activeSessions.first['session_id'];
      _expandedSessions[firstSessionId] = true;
    }
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
    if (_globalAuthToken.isNotEmpty && _userId.isNotEmpty) {
      _actingForUsers[_userId] = _globalAuthToken;
    }
    // Initialize all users as selected (checked)
    _userSelection = {
      for (var userId in _actingForUsers.keys) userId: true,
    };
    setState(() {});
  }

  void _saveActingForUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final actingForUsersJson = jsonEncode(_actingForUsers);
    await prefs.setString('acting_for_users', actingForUsersJson);
  }

  void _toggleSessionExpansion(String sessionId) {
    setState(() {
      _expandedSessions[sessionId] = !(_expandedSessions[sessionId] ?? false);
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tokenController = TextEditingController();
        return AlertDialog(
          title: const Text('Add User To Act For'),
          content: TextField(
            controller: tokenController,
            decoration: const InputDecoration(
              labelText: 'Authentication Token',
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

  void _addUserByToken(String token) async {
    try {
      // Retrieve user data using the provided token
      final userData = await ApiService().studentValidateAuthToken(token);
      final userId = userData['i_am'];
      if (!_actingForUsers.containsKey(userId)) {
        setState(() {
          _actingForUsers[userId] = token;
          _userSelection[userId] = true; // Initially checked
          _saveActingForUsers();
        });
      }
    } catch (e) {
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

  String _getJoiningStatus(String sessionId) {
    final selectedUserIds = _userSelection.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key);
    final session = _sessions[sessionId] ?? {};
    final participation = session['participation'] ?? {};
    final statuses = selectedUserIds.map((userId) {
      return participation[userId] ?? 'Unspecified';
    }).toSet();
    if (statuses.isEmpty) return 'Unspecified';
    return statuses.length == 1 ? statuses.first : '-';
  }

  void _updateParticipation(String sessionId, String? joining) async {
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
    } catch (e) {
      _showError('Failed to update participation: ${e.toString()}');
    }

    _refreshData();
  }

  void _refreshData() async {
    try {
      final data = await ApiService().anonymousShowInfo();
      setState(() {
        _sessions = data['sessions'];
        _users.addAll(data['users']); // Update user data
      });
    } catch (e) {
      _showError('Failed to refresh data: ${e.toString()}');
    }
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

  Widget _buildUserList() {
    return Column(
      children: [
        ..._actingForUsers.keys.map((userId) {
          final userName = _users[userId]?['name'] ?? 'Unknown';
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
          label: const Text('Add User To Act For'),
          onPressed: _showAddUserDialog,
        ),
      ],
    );
  }

  Widget _buildSessionRow(Map<String, dynamic> session) {
    final sessionId = session['session_id'];
    final coachId = session['coach'];
    final coachName = _users[coachId]?['name'] ?? 'Unknown';
    final comment = session['comment'] ?? '';
    final startTime =
    DateTime.fromMillisecondsSinceEpoch(session['start_time'] * 1000);
    final joiningStatus = _getJoiningStatus(sessionId);
    final isExpanded = _expandedSessions[sessionId] ?? false;

    return Column(
      children: [
        ListTile(
          title: Text(_formatDateTime(startTime)),
          subtitle: Text('Coach: $coachName\n$comment'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown for participation status
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
                    _updateParticipation(sessionId, value);
                  }
                },
              ),
              // Icon button to toggle participation details
              IconButton(
                icon: Icon(isExpanded
                    ? Icons.expand_less
                    : Icons.expand_more),
                tooltip: 'See participation',
                onPressed: () => _toggleSessionExpansion(sessionId),
              ),
            ],
          ),
        ),
        if (isExpanded) _buildParticipationDetails(sessionId),
        const Divider(),
      ],
    );
  }

  Widget _buildParticipationDetails(String sessionId) {
    // Get participation data for the session
    final session = _sessions[sessionId] ?? {};
    final participation = session['participation'] ?? {};
    final yesUsers = <String>[];
    final maybeUsers = <String>[];
    final noUsers = <String>[];

    participation.forEach((userId, status) {
      final userName = _users[userId]?['name'] ?? 'Unknown';
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
              style: TextStyle(fontWeight: FontWeight.bold),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          buildParticipationLine('Yes', yesUsers),
          buildParticipationLine('Maybe', maybeUsers),
          buildParticipationLine('No', noUsers),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getWeekday(dateTime.weekday)} ${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
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

  @override
  Widget build(BuildContext context) {
    // Filter out sessions that are not scheduled
    final activeSessions = _sessions.values
        .where((session) => session['state'] == 'scheduled')
        .toList();

    // Sort sessions by 'start_time' in ascending order
    activeSessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));

    return Column(
      children: [
        // Display the list of users you're acting for dynamically sized
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildUserList(),
        ),
        const Divider(),
        // Display the list of sessions
        Expanded(
          child: ListView(
            children:
            activeSessions.map((session) => _buildSessionRow(session)).toList(),
          ),
        ),
      ],
    );
  }
}

```

Content of ../app/lib/screens/register_participation_screen.dart:
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterParticipationScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> users;
  final Map<String, dynamic>? intendedParticipation;
  final String authToken;

  const RegisterParticipationScreen({super.key, 
    required this.session,
    required this.users,
    this.intendedParticipation,
    required this.authToken,
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
      await ApiService().coachRegisterParticipation(
          widget.authToken, widget.session['session_id'], _selectedParticipants);
      if (mounted) Navigator.pop(context, true);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close'),
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
        title: Text('Register Participation'),
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
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

Content of ../app/lib/screens/show_auth_token_screen.dart:
```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class ShowAuthTokenScreen extends StatefulWidget {
  final String authToken;
  final Map<String, dynamic> users;

  const ShowAuthTokenScreen({super.key, required this.authToken, required this.users});

  @override
  ShowAuthTokenScreenState createState() => ShowAuthTokenScreenState();
}

class ShowAuthTokenScreenState extends State<ShowAuthTokenScreen> {
  String? _selectedUserId;
  String? _retrievedAuthToken;

  void _retrieveAuthToken() async {
    if (_selectedUserId == null) {
      _showError('Please select a user.');
      return;
    }
    try {
      final result = await ApiService()
          .adminShowAuthToken(widget.authToken, _selectedUserId!);
      setState(() {
        _retrievedAuthToken = result['auth_token'];
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  List<DropdownMenuItem<String>> _getUserDropdownItems() {
    return widget.users.entries
        .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value['name']),
            ))
        .toList();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (_retrievedAuthToken != null) {
      Clipboard.setData(ClipboardData(text: _retrievedAuthToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth token copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Authentication Token'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'User'),
              items: _getUserDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  _retrievedAuthToken = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a user.';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retrieveAuthToken,
              child: Text('Retrieve Auth Token'),
            ),
            if (_retrievedAuthToken != null) ...[
              SizedBox(height: 20),
              SelectableText('Auth Token: $_retrievedAuthToken'),
              ElevatedButton(
                onPressed: _copyToClipboard,
                child: Text('Copy to Clipboard'),
              ),
            ],
          ],
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
    final url = Uri.parse('https://struer-taekwondo-public.s3.eu-central-1.amazonaws.com/data.json');
    final response = await http.get(url, headers: {
      'Cache-Control': 'no-cache'
    });
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

  Future<void> coachUpdateTrainingSession(
      String authToken, String sessionId, String state) async {
    await _post({
      'action': 'coach_update_training_session',
      'auth_token': authToken,
      'session_id': sessionId,
      'session_state': state,
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
      if (users[userId]['auth_token'] == authTokenHashed && users[userId]['auth_token'] != null) {
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
import './screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure plugin services are initialized
  await _initializeAuthToken();  // Initialize the auth token if it's not present
  runApp(StruerTKDApp());
}

Future<void> _initializeAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  // Check if 'auth_token' is not set and initialize it if necessary
  if (prefs.getString('auth_token') == null) {
    await prefs.setString('auth_token', '');
  }
}

class StruerTKDApp extends StatelessWidget {
  const StruerTKDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Struer Taekwondo App v0.2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
```

