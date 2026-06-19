import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<String> askQuestion(String question) async {
    final url = Uri.parse('$_baseUrl/query/ask');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'] as String;
    } else {
      throw Exception('Failed to get answer. Status: ${response.statusCode}');
    }
  }

  Future<RecommendationResponse> getRecommendations(UserProfile profile) async {
    final url = Uri.parse('$_baseUrl/query/recommend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RecommendationResponse.fromJson(data);
    } else {
      throw Exception(
          'Failed to get recommendations. Status: ${response.statusCode}');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
