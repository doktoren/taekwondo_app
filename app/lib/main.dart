import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'screens/home_screen.dart';

/// Main entry point of the Struer Taekwondo app.
///
/// Initializes the application, ensuring an authentication token is available.
/// Sets up the root widget with a DataProvider and runs the HomeScreen.
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
