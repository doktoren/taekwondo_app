Given below is the full implementation of an app written in Flutter and a backend written as a Lambda Function.

Analyze it carefully.

I'd like you to make a few small updates:

* Currently, when you update a user in the update_user_screen.dart then the current
  username isn't being displayed. This has previously been working so it's most likely
  a bug introduced in connection with the data provider.
* The theory tab allows you to train the meaning of the Korean taekwondo commmands.
  I'd like you to extend this tab such that it can also train your active memory of
  the taekwondo commands given their description in Danish. That is; to go the other way.
  Rename the button "Start quiz" to "Træn skjult forklaring", keep the button "Træn" as is
  and introduce a new button "Træn skjult udtryk" for the new case where the Danish
  explanation is originally shown and you have to guess the matching taewondo command.
* I'd like you to change the link tab into a kind of about tab.
  The 3 links should be rearranged such that they're on the same link.
  Change their styling to make it more clear that they're actually links.
  Add a horizontal ruler below.
  Below the horizontal ruler add a title "dokumentation". This should be followed the an
  unfoldable section for each of the other visible tabs (i.e. depending on your user role).
  Please document the purpose and how to use each screen. Remember to add details such as
  the coach section only allows you to register the participation for a training session
  that will start within 10 minutes or already has started or ended.

If anything is unclear or you need more context the please ask before proceeding
- this is important! I've noticed that you proceed with a solution even though
I've sometimes forgot to add a file.

I'd like you to procedure the full content of the files you modify or add.



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


# Implementation omitted
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
          title: Text('Website'),
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

Content of ../app/lib/screens/theory_data.dart:
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

Content of ../app/lib/screens/theory_tab.dart:
```
// theory_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb and defaultTargetPlatform
import 'theory_data.dart';

class TheoryTab extends StatefulWidget {
  const TheoryTab({super.key});

  @override
  TheoryTabState createState() => TheoryTabState();
}

class TheoryTabState extends State<TheoryTab> {
  List<Belt> selectedBelts = [];
  List<MapEntry<String, String>> terms = [];
  Map<int, bool> beltSelection = {};
  bool isQuizStarted = false;
  bool showAllExplanations = false; // For the "Træn" button functionality
  List<bool> showExplanationList = [];
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    beltSelection = {for (var belt in allBelts) belt.level: false};
  }

  @override
  Widget build(BuildContext context) {
    if (!isQuizStarted) {
      // Belt selection screen
      return Scaffold(
        // Removed AppBar as per your request
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      'Vælg bælter',
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _selectAllBelts,
                        child: const Text('Vælg Alle'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _deselectAllBelts,
                        child: const Text('Fravælg Alle'),
                      ),
                    ],
                  ),
                  ...allBelts.map((belt) {
                    return CheckboxListTile(
                      title: Text(belt.name),
                      value: beltSelection[belt.level],
                      onChanged: (bool? value) {
                        setState(() {
                          beltSelection[belt.level] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startQuiz,
                    child: const Text('Start Quiz'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _startTraining,
                    child: const Text('Træn'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Quiz interface with swipe navigation
      return Scaffold(
        // No AppBar to remove the header
        body: _buildQuiz(),
      );
    }
  }

  Widget _buildQuiz() {
    if (terms.isEmpty) {
      return Center(
        child: Text('Ingen spørgsmål at vise.'),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: terms.length,
          itemBuilder: (context, index) {
            var term = terms[index];
            bool showExplanation = showAllExplanations || showExplanationList[index];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Spørgsmål ${index + 1} af ${terms.length}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    term.key,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!showExplanation)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showExplanationList[index] = true;
                        });
                      },
                      child: const Text('Vis forklaring'),
                    )
                  else
                    Text(
                      term.value,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
        // Navigation buttons for desktop browsers
        if (kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_left),
                onPressed: _previousPage,
              ),
            ),
          ),
        if (kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_right),
                onPressed: _nextPage,
              ),
            ),
          ),
      ],
    );
  }

  void _previousPage() {
    if (pageController.hasClients) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _nextPage() {
    if (pageController.hasClients) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _selectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = true;
      }
    });
  }

  void _deselectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = false;
      }
    });
  }

  void _startQuiz() {
    _prepareQuiz(showAll: false);
  }

  void _startTraining() {
    _prepareQuiz(showAll: true);
  }

  void _prepareQuiz({required bool showAll}) {
    selectedBelts = allBelts
        .where((belt) => beltSelection[belt.level] == true)
        .toList();

    if (selectedBelts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg mindst ét bælte for at starte quizzen')),
      );
      return;
    }

    terms = [];
    for (var belt in selectedBelts) {
      for (var category in belt.categories.values) {
        terms.addAll(category.entries);
      }
    }

    terms.shuffle();

    // Initialize the list to track which explanations are shown
    showExplanationList = List<bool>.filled(terms.length, false);

    setState(() {
      isQuizStarted = true;
      showAllExplanations = showAll;
    });
  }
}
```

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = dataProvider.userData['users'][widget.userId];
      setState(() {
        _name = user['name'];
        _role = user['role'];
      });
    });
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
    final url = Uri.parse(
        'https://struer-taekwondo-public.s3.eu-central-1.amazonaws.com/data.json');
    final response = await http.get(url, headers: {
      'Cache-Control': 'no-cache',
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
