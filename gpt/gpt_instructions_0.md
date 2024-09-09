(When I generated the query there were more instructions in the beginning.
Informing o1-preview that it should generate a Flutter app).

The python backend implements an API exposed as a single endpoint.
It serves as a backend for an app to be used for handling training sessions
for a local Taekwondo club.
Further down follows a description of both the possible actions of the endpoint
and a description of how the taekwondo app should be structured.
It should be clear which actions of the endpoint should be called by which parts
of the taekwondo app.

The first time the endpoint is called it will initialize with some example users
and data. I'll execute this first call manually (command line curl) and I'll then
download the authorization tokens for those users manully from S3 and distribute
them e.g. by mail or SMS to those persons.

Given the authentication token for an admin user new (admin/coach/student) users can
be created. The authentication tokens for created users should be shown and allow
the user to easily copy it to e.g. an SMS or email.

# App design

When the app first starts one should enter the authentication token.
This should be stored in the app such that it only need to be entered once.

Second, the app should call the action anonymous_show_info and store the information locally.

Depending on the role of the user then 1, 2 or 3 tabs should be shown labelled "Student", "Coach" and "Admin".
* An admin should see all 3 tabs
* A coach should see the tabs "Student" and "Coach"
* A student should see the tab "Student"

## Admin tab

The admin tab should contain a list of vertically aligned buttons:

* Create user
* Delete user
* Show authentication token for user

## Coach tab

The couch tab should have a button in the top:

* Add training session

It should the contain a vertical listing with one line per training session.
These should be sorted in increasing order according to start time.

Next to a training session that starts within 10 minutes or already has started there
should be a button "Register partipation". Next to the remaining training sessions
there should be a button "Cancel".

That is; the layout should be as show below.
Note that the shown times are "start_time" in local time zone.

| Training session data     | Coach     | Comment                           | Action      |
|---------------------------+-----------+-----------------------------------+-------------|
| Tuesday  2024-10-01 19:00 | Jesper    | Hanbon med fokus på stande og ... | Register P. |
| Thursday 2024-10-03 19:00 | John      | Taekwondo of the day - tema       | Cancel      |
| Monday   2024-10-03 19:00 | John      | Familie Taekwondo                 | Cancel      |


## Student tab

The layout is shown below. In the "Joining?" column each row should contain a dropdown with
the options "Yes", "No", "Maybe" and "Unspecified".
When the user makes a change to the dropdown it should call the action student_register_participation
and map "Unspecified" to null.

| Training session data     | Coach     | Comment                           | Joining?    |
|---------------------------+-----------+-----------------------------------+-------------|
| Tuesday  2024-10-01 19:00 | Jesper    | Hanbon med fokus på stande og ... | No          |
| Thursday 2024-10-03 19:00 | John      | Taekwondo of the day - tema       | Maybe       |
| Monday   2024-10-03 19:00 | John      | Familie Taekwondo                 | Unspecified |
