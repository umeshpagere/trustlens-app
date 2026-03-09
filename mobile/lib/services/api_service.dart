import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ApiService {
  // For Android emulator use 10.0.2.2, for iOS simulator use 127.0.0.1,
  // for physical devices use your machine's LAN IP.
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? _resolveBaseUrl();

  static String _resolveBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001';
    }
    // Updated to match current machine IP
    return 'http://192.0.0.2:5001';
  }

  /// Analyze text and/or image URL — mirrors POST /api/analyze
  Future<AnalysisResponse> analyze({
    String? text,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (text != null && text.trim().isNotEmpty) body['text'] = text.trim();
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      body['imageUrl'] = imageUrl.trim();
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return AnalysisResponse.fromJson(json);
        }
        throw ApiException(json['message'] ?? 'Analysis failed');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
          json['message'] ?? 'Server error ${response.statusCode}');
    } on SocketException {
      throw ApiException('Cannot connect to server. Check your internet or backend status.');
    } on TimeoutException {
      throw ApiException('Analysis timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  /// Health check
  Future<bool> isHealthy() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
