import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Screen for updating user information or deleting a user.
///
/// Allows administrators to modify a user's name and role.
/// Provides an option to delete the user, with a confirmation prompt to prevent accidental deletions.
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
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final user = dataProvider.userData['users'][widget.userId];
      if (user != null) {
        setState(() {
          _name = user['name'];
          _role = user['role'];
          _isLoading = false;
        });
      }
    }
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
    if (_isLoading) {
      // Show loading indicator while fetching user data
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update User'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
