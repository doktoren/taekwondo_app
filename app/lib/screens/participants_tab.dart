import 'dart:convert'; // Added
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Participation tab for viewing and registering training sessions.
///
/// Allows participants to view upcoming training sessions and register their attendance.
/// Users can select sessions and indicate their participation status (Yes, No, Maybe).
/// Supports acting on behalf of multiple users, enabling registration for others (e.g., parents for children).
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
