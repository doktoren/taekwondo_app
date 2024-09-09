Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

Recently I updated the backend.
In particular the API anonymousShowInfo in the Flutter app now returned a slightly differently formatted json structure.

The authentication tokens are stored SHA hashed in the public data available from S3.
This allows the app to check whether it's configured authentication hash is valid without calling the somewhat slow lambda function.
The SHA hashed authentication tokens were added recently and the app may need more implementation changes to handle them properly.

I know that the app is currently a bit broken. For examply you cannot see all 4 tabs if you're logged in as an admin.

Please analyse the app and the backend and make suggested bug fixes.
Ask if anything is unclear or if you need more context.

What I'm aiming for here are some smaller fixes and changes.
Please show them in a diff like output and keep your answer short - I'd rather ask again for more changes.
