import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Service class for handling API requests to the backend.
///
/// Contains methods for all API actions, including user management, session management,
/// and participation registration.
/// Handles HTTP requests, response parsing, and error handling.
class ApiService {
  final String _lambdaBaseUrl = 'https://${const String.fromEnvironment(
    'LAMBDA_HOSTNAME',
    defaultValue: 'giiucpryj6hizlsgwvoezpzura0cvcsg.lambda-url.eu-central-1.on.aws',  // Test setup
  )}/';

  final String _s3BaseUrl = 'https://${const String.fromEnvironment(
    'S3_HOSTNAME',
    defaultValue: 'taekwondo-test-public.s3.eu-central-1.amazonaws.com',  // Test setup
  )}/data.json';

  Future<dynamic> _post(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_lambdaBaseUrl),
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$_s3BaseUrl?t=$timestamp');
    final response = await http.get(url);
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
