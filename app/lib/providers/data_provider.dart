import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DataProvider for managing user data and authentication state.
///
/// This `ChangeNotifier` handles loading and refreshing user data,
/// authentication tokens, and user roles. It provides methods to
/// log in, log out, and notify listeners of data changes.
/// Used throughout the app to access user-related information.
class DataProvider extends ChangeNotifier {
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _authToken = '';
  String get authToken => _authToken;

  String _role = '';
  String get role => _role;

  String _userId = '';
  String get userId => _userId;

  Future<void> loadUserData() async {
    _isLoading = true;
    // Defer notifyListeners to avoid calling it during build
    Future.microtask(() => notifyListeners());

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';

    try {
      final data = await ApiService().anonymousShowInfo();
      _userData = data;

      final userId = await getUserIdFromToken(_authToken);
      if (userId != null) {
        final users = data['users'] as Map<String, dynamic>;
        final user = users[userId];
        _role = user['role'];
        _userId = userId;
        _userData['i_am'] = userId;
      } else {
        _role = 'Anonymous';
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<String?> getUserIdFromToken(String authToken) async {
    try {
      final userData = await ApiService().studentValidateAuthToken(authToken);
      return userData['i_am'];
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshData() async {
    await loadUserData();
  }

  void setAuthToken(String authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = '';
    _role = 'Anonymous';
    _userId = '';
    _userData = {};
    notifyListeners();
  }
}
