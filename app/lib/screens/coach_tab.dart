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

/// Coach tab providing functionalities for coaches.
///
/// This tab enables coaches to manage training sessions by adding new sessions,
/// updating existing ones, registering participant attendance, and viewing historical participation data.
/// It displays a list of training sessions with management options for each session.
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
