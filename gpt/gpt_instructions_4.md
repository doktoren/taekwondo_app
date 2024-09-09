Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

I'd like you to make some changes to `coach_tab.dart`

A) I've update the backend such that the method `coach_add_training_session` adds the coach as a participant in the training session. So the app should no longer do this as a separate call as part of creating a new session.
B) When the state of a session is archived it should still show a dropdown list with this value as the single item.

I'd like you to make a change to `participants_tab.dart` as well. The "see participation" should be enabled for the first session in the list.
