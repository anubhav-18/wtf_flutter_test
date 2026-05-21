import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';
import 'dev_log_service.dart';

/// Thin HTTP client that talks to the shared token-server backend.
/// All repositories use this instead of writing directly to local Hive.
class ApiClient {
  ApiClient._();

  static final _base = AppConstants.tokenServerBaseUrl;

  static Future<List<Map<String, dynamic>>> getList(String path,
      [Map<String, String>? query]) async {
    try {
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      }
      DevLogService.add('[API]', 'GET $path → ${res.statusCode}');
    } catch (e) {
      DevLogService.add('[API]', 'GET $path error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> post(
      String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30)); // 30s for image payloads
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      DevLogService.add('[API]', 'POST $path → ${res.statusCode}: ${res.body}');
    } catch (e) {
      DevLogService.add('[API]', 'POST $path error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> patch(
      String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .patch(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      DevLogService.add('[API]', 'PATCH $path → ${res.statusCode}: ${res.body}');
    } catch (e) {
      DevLogService.add('[API]', 'PATCH $path error: $e');
    }
    return null;
  }

  static Future<void> patchQuery(
      String path, Map<String, String> query) async {
    try {
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      await http.patch(uri).timeout(const Duration(seconds: 5));
    } catch (e) {
      DevLogService.add('[API]', 'PATCH $path error: $e');
    }
  }

  /// Returns the error string from the server body, or null on success.
  static Future<String?> postForError(
      String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 || res.statusCode == 201) return null;
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded['error'] as String? ?? 'Server error ${res.statusCode}';
    } catch (e) {
      return 'Network error: $e';
    }
  }

  static Future<String?> patchForError(
      String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .patch(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return null;
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded['error'] as String? ?? 'Server error ${res.statusCode}';
    } catch (e) {
      return 'Network error: $e';
    }
  }
}
