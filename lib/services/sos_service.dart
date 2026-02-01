import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/config/api_config.dart';
import '../core/services/profile_service.dart';

/// Abstract SOS service interface for handling alert operations
abstract class SOSService {
  /// Send SOS alert to backend
  Future<SOSResponse> sendSOSAlert({
    required String sosId,
    required String sosType,
    required Position location,
    Map<String, dynamic>? userInfo,
  });
}

/// HTTP-based implementation for communicating with backend
class HTTPSOSService implements SOSService {
  static const int _timeoutSeconds = 30;
  
  @override
  Future<SOSResponse> sendSOSAlert({
    required String sosId,
    required String sosType,
    required Position location,
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      // Get unique user ID for self-filtering
      final senderId = await ProfileService.getUserId();
      
      final sosData = {
        'sos_id': sosId,
        'sos_type': sosType,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'timestamp': location.timestamp.toIso8601String(),
        },
        'userInfo': userInfo ?? {
          'deviceId': 'mobile-device',
          'platform': 'flutter',
          'appVersion': '1.0.0'
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'sender_id': senderId, // Include sender ID for client-side filtering
      };

      final response = await http.post(
        Uri.parse(ApiConfig.sosEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sosData),
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SOSResponse.success(
          messageId: data['messageId']?.toString() ?? data['sosId']?.toString() ?? 'unknown',
          topic: data['topic']?.toString() ?? 'unknown',
          message: data['message']?.toString() ?? 'SOS alert processed successfully',
        );
      } else {
        debugPrint('SOS request failed: ${response.statusCode}');
        String errorMessage = 'Unexpected response from server.';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        } catch (_) {
          // Keep default error message for non-JSON responses.
        }
        return SOSResponse.error(
          error: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('SOS request timed out: $e');
      return SOSResponse.error(
        error: 'Request timed out. The backend may be unavailable. Please try again.',
        originalError: e.toString(),
      );
    } on SocketException catch (e) {
      debugPrint('SOS request failed with socket error: $e');
      return SOSResponse.error(
        error: 'Unable to reach the backend server. Please check your connection and try again.',
        originalError: e.toString(),
      );
    } on http.ClientException catch (e) {
      debugPrint('SOS request failed with client error: $e');
      return SOSResponse.error(
        error: 'Unable to reach the backend server. Please try again.',
        originalError: e.toString(),
      );
    } on FormatException catch (e) {
      debugPrint('SOS request failed with format error: $e');
      return SOSResponse.error(
        error: 'Invalid response from server.',
        originalError: e.toString(),
      );
    } catch (e) {
      debugPrint('SOS request failed: $e');
      return SOSResponse.error(
        error: 'Failed to send SOS alert. Please try again.',
        originalError: e.toString(),
      );
    }
  }
}

/// Response model for SOS operations
class SOSResponse {
  final bool success;
  final String? messageId;
  final String? topic;
  final String? message;
  final String? error;
  final int? statusCode;
  final String? originalError;

  SOSResponse({
    required this.success,
    this.messageId,
    this.topic,
    this.message,
    this.error,
    this.statusCode,
    this.originalError,
  });

  factory SOSResponse.success({
    required String messageId,
    required String topic,
    required String message,
  }) {
    return SOSResponse(
      success: true,
      messageId: messageId,
      topic: topic,
      message: message,
    );
  }

  factory SOSResponse.error({
    required String error,
    int? statusCode,
    String? originalError,
  }) {
    return SOSResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'SOSResponse(success: $success, messageId: $messageId, topic: $topic)';
    } else {
      return 'SOSResponse(success: $success, error: $error, statusCode: $statusCode)';
    }
  }
}

/// Riverpod provider for SOS service
final sosServiceProvider = Provider<SOSService>((ref) {
  return HTTPSOSService();
});