import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/api_service/global/utils.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/api_service/urls.dart';
import 'package:jin_reflex_new/model/tretment_model.dart';
import 'package:jin_reflex_new/services/session_manager.dart';

class Response {
  final int statusCode;
  final dynamic data;
  final Map<String, String>? headers;

  Response({
    required this.statusCode,
    required this.data,
    this.headers,
  });

  @override
  String toString() => 'Response(status: $statusCode, data: $data)';
}

class ApiService {
  String? get tokens => AppPreference().getString(PreferencesKey.token);

  Uri _resolveUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    String url = endpoint;
    if (!endpoint.startsWith('http://') && !endpoint.startsWith('https://')) {
      final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final ep = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      url = '$base$ep';
    }
    final uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...queryParams.map((k, v) => MapEntry(k, v.toString())),
        },
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final token = AppPreference().getString(PreferencesKey.token);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<Response?> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    log(endpoint);
    try {
      final uri = _resolveUri(endpoint, queryParams);
      final response = await http
          .get(uri, headers: _buildHeaders({'Content-Type': 'application/json'}))
          .timeout(const Duration(seconds: 40));

      _checkUnauthorized(response.statusCode);
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Response?> postRequest(String endpoint, dynamic data) async {
    log("Request Dataddd: $data");
    log("Requestsss Data: $endpoint");
    try {
      final uri = _resolveUri(endpoint);
      final headers = _buildHeaders();

      http.Response response;
      if (data is Map) {
        final bodyMap = <String, String>{};
        data.forEach((k, v) {
          if (v != null) bodyMap[k.toString()] = v.toString();
        });
        response = await http
            .post(uri, headers: headers, body: bodyMap)
            .timeout(const Duration(seconds: 40));
      } else if (data is String) {
        headers['Content-Type'] = 'application/json';
        response = await http
            .post(uri, headers: headers, body: data)
            .timeout(const Duration(seconds: 40));
      } else {
        headers['Content-Type'] = 'application/json';
        response = await http
            .post(uri, headers: headers, body: jsonEncode(data))
            .timeout(const Duration(seconds: 40));
      }

      _checkUnauthorized(response.statusCode);
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Response?> putRequest(String endpoint, dynamic data) async {
    try {
      final uri = _resolveUri(endpoint);
      final headers = _buildHeaders({'Content-Type': 'application/json'});
      final body = data is String ? data : jsonEncode(data);
      final response = await http
          .put(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 40));

      _checkUnauthorized(response.statusCode);
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Response?> deleteRequest(String endpoint) async {
    try {
      final uri = _resolveUri(endpoint);
      final headers = _buildHeaders({'Content-Type': 'application/json'});
      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 40));

      _checkUnauthorized(response.statusCode);
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Response _processResponse(http.Response response) {
    dynamic decodedData;
    try {
      decodedData = jsonDecode(response.body);
    } catch (_) {
      decodedData = response.body;
    }

    if (response.statusCode >= 400) {
      _handleHttpError(response.statusCode, decodedData);
    }

    return Response(
      statusCode: response.statusCode,
      data: decodedData,
      headers: response.headers,
    );
  }

  void _checkUnauthorized(int statusCode) async {
    if (statusCode == 401) {
      await SessionManager.forceLogout(
        message: "Session expired. Please login again.",
        notifyServer: false,
      );
    }
  }

  void _handleHttpError(int statusCode, dynamic body) {
    String? message;
    if (body is Map && body.containsKey('message')) {
      message = body['message']?.toString();
    } else if (body is String && body.length < 200 && !body.contains('<html')) {
      message = body;
    }

    switch (statusCode) {
      case 400:
        Utils().showToastMessage(message ?? "Bad Request");
        break;
      case 401:
        Utils().showToastMessage(message ?? "Unauthorized");
        break;
      case 403:
        Utils().showToastMessage(message ?? "Forbidden");
        break;
      case 404:
        Utils().showToastMessage(message ?? "Not Found");
        break;
      case 500:
        Utils().showToastMessage(message ?? "Internal Server Error");
        break;
      default:
        if (message != null && message.isNotEmpty) {
          Utils().showToastMessage(message);
        }
        break;
    }
  }

  void _handleError(dynamic error) {
    if (error is SocketException) {
      print("No Internet connection. Please check your network.");
      Utils().showToastMessage("No Internet connection. Please check your network.");
    } else {
      print("Unexpected error: $error");
      Utils().showToastMessage("Unexpected error: $error");
    }
  }
}

extension DriverLocationApi on ApiService {
  Future<Response?> postDriverLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    String? authorizationToken,
  }) async {
    final token = (authorizationToken ??
            AppPreference().getString(PreferencesKey.token).toString())
        .trim();

    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    };

    try {
      final uri = Uri.parse(driverLocationEndpoint);
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 40));

      return _processResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
}

class TreatmentService {
  /// HTML madhun JSON extract karto
  static Map<String, dynamic>? _extractJson(String html) {
    try {
      final start = html.indexOf('{');
      final end = html.lastIndexOf('}');
      if (start == -1 || end == -1) return null;

      final jsonString = html.substring(start, end + 1);
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint("❌ HTML → JSON error: $e");
      return null;
    }
  }

  /// HTML response → Dart Model
  static TreatmentResponse? parseTreatmentFromHtml(String htmlResponse) {
    final jsonMap = _extractJson(htmlResponse);
    if (jsonMap == null) return null;

    return TreatmentResponse.fromJson(jsonMap);
  }
}

