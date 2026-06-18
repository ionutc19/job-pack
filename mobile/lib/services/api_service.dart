import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/job_fit.dart';
import '../models/profile_boost.dart';
import '../models/apply_letter.dart';
import 'user_identity.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.baseUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers {
    final identity = UserIdentity();
    return {
      'Content-Type': 'application/json',
      'X-User-Id': identity.userId,
      'X-Device-Id': identity.deviceId,
    };
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 429) {
      final data = jsonDecode(response.body);
      final detail = data['detail'];
      final reason = detail is Map ? (detail['reason'] ?? 'limit_reached') : 'limit_reached';
      throw UsageLimitException(reason);
    }
    if (response.statusCode != 200) {
      throw ApiException('Request failed: ${response.statusCode}', response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw ApiException('Request failed: ${response.statusCode}', response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<JobFitResult> analyzeJobFit({
    required String cvText,
    required String jobDescription,
    String language = 'en',
  }) async {
    final data = await _post('/api/job-fit/analyze', {
      'cv_text': cvText,
      'job_description': jobDescription,
      'language': language,
    });
    return JobFitResult.fromJson(data);
  }

  Future<ProfileBoostResult> generateProfileBoost({
    String headline = '',
    String about = '',
    String experience = '',
    String language = 'en',
  }) async {
    final data = await _post('/api/profile-boost/generate', {
      'headline': headline,
      'about': about,
      'experience': experience,
      'language': language,
    });
    return ProfileBoostResult.fromJson(data);
  }

  Future<ApplyLetterResult> generateCoverLetter({
    required String cvText,
    required String jobDescription,
    String tone = 'professional',
    String language = 'en',
  }) async {
    final data = await _post('/api/apply-letter/generate', {
      'cv_text': cvText,
      'job_description': jobDescription,
      'tone': tone,
      'language': language,
    });
    return ApplyLetterResult.fromJson(data);
  }

  Future<Map<String, dynamic>> getEntitlements() async {
    return await _get('/api/entitlements/me');
  }

  Future<bool> submitFeedback({
    required String category,
    required String title,
    required String description,
    String email = '',
  }) async {
    final data = await _post('/api/feedback', {
      'category': category,
      'title': title,
      'description': description,
      'email': email,
    });
    return data['success'] as bool;
  }

  Future<Map<String, dynamic>> verifyPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    return await _post('/api/entitlements/verify-purchase', {
      'product_id': productId,
      'purchase_token': purchaseToken,
    });
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UsageLimitException implements Exception {
  final String reason;
  const UsageLimitException(this.reason);

  @override
  String toString() => 'UsageLimitException: $reason';
}
