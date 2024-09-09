Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

The backend consists of a number of mostly state mutating actions.
Whenever the backend updates the state it updates a file on S3 that the app can download to update its state.

Currently the app suffers from the problem that if trigger an update of the state in one tab the updated state doesn't get reflected in other tabs before you explicitly click the refresh buttom.

I'd like you to do a possibly bigger overhaul of the app to fix this problem.
That is; whenever the state is updated somewhere then make sure the changes propagate.
It's important that state is being maintained in some industry standard way.

You can see in the backend implementation which actions are updating the state.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.
