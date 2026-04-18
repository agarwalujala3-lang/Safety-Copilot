import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client = http.Client();
  final List<String> _baseUrls = AppConfig.allApiBaseUrls;
  int _preferredBaseIndex = 0;

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) =>
      _request(path, method: 'GET', token: token);

  Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) =>
      _request(path, method: 'POST', token: token, body: body);

  Future<Map<String, dynamic>> _request(
    String path, {
    required String method,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final baseIndexes = _orderedBaseIndexes();
    final errors = <String>[];
    ApiException? apiError;
    Exception? networkError;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    for (final index in baseIndexes) {
      final baseUrl = _baseUrls[index];
      final uri = Uri.parse('$baseUrl$path');

      try {
        final response = await _dispatch(
          uri,
          method: method,
          headers: headers,
          body: body,
        ).timeout(const Duration(seconds: 15));

        final payload = _decode(response);
        if (response.statusCode >= 500) {
          errors.add('Server ${response.statusCode} from $baseUrl');
          continue;
        }
        if (response.statusCode >= 400) {
          apiError = ApiException(
            payload['message'] as String? ??
                'Request failed (${response.statusCode})',
          );
          break;
        }

        _preferredBaseIndex = index;
        return payload;
      } on TimeoutException {
        errors.add('Timeout contacting $baseUrl');
      } on SocketException catch (e) {
        networkError = e;
        errors.add('Network error contacting $baseUrl');
      } on http.ClientException catch (e) {
        networkError = e;
        errors.add('Client error contacting $baseUrl');
      }
    }

    if (apiError != null) {
      throw apiError;
    }
    if (networkError != null) {
      throw ApiException(
        'Unable to reach safety servers. '
        'Please check internet and try again. (${errors.join(' | ')})',
      );
    }

    throw ApiException('Request failed. ${errors.join(' | ')}');
  }

  List<int> _orderedBaseIndexes() {
    final indexes = <int>[];
    if (_baseUrls.isNotEmpty) {
      indexes.add(_preferredBaseIndex.clamp(0, _baseUrls.length - 1));
    }
    for (var i = 0; i < _baseUrls.length; i++) {
      if (!indexes.contains(i)) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  Future<http.Response> _dispatch(
    Uri uri, {
    required String method,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    switch (method) {
      case 'POST':
        return _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      case 'GET':
        return _client.get(uri, headers: headers);
      default:
        throw ApiException('Unsupported method $method');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'message': response.body};
    }
  }
}
