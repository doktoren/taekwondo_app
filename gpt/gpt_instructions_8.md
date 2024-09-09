Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

The backend consists of a number of mostly state mutating actions.
Whenever the backend updates the state it updates a file on S3 that the app can download to update its state.

I recently asked you to update the app to use a data provider.

Unfortunately a few details got lost in that refactoring.
I'd like you to fix those details now.

For example, in `app/lib/screens/participants_tab.dart` this section got lost in the `initState()` method:

```
    if (activeSessions.isNotEmpty) {
      // Sort sessions by 'start_time' in ascending order
      activeSessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));
      final firstSessionId = activeSessions.first['session_id'];
      _expandedSessions[firstSessionId] = true;
    }
```

The list of sessions in both the participation tab and the coach tab should be ordered according to session start time.
Also, the oldest shown session should start in an unfolded state.

Also, please analyze the implementation and try to identify errors or inconsistencies that should be fixed as well.
However, start by explaining me those error or inconsistencies and let me decide whether they should be fixed as well.

If anything is unclear or you need more context the please ask before proceeding.

I'd like you to procedure the full content of the files you modify or add.
