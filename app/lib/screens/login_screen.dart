import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

/// User login screen.
///
/// Allows the user to enter their login code (authentication token).
/// Saves the token and navigates to the HomeScreen upon successful login.
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
