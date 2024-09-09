import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ensure this import is present
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import './create_user_screen.dart';
import './update_user_screen.dart';
import '../services/api_service.dart';

/// Admin tab providing administrative functionalities.
///
/// This tab allows administrators to manage users, including creating new users,
/// updating existing users, and viewing authentication tokens.
/// It displays a list of users with options to update or show the auth token for each.
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
