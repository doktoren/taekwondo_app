import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Screen for registering participant attendance for a training session.
///
/// Displays a list of participants, pre-selecting those who indicated they would attend.
/// Allows the coach to confirm or adjust the actual attendance before submitting to the backend.
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
