import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Screen for creating a new user.
///
/// Provides a form for administrators to input the new user's name and role.
/// Upon successful creation, displays the authentication token for the new user.
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
