import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/config/api_config.dart';

/// Abstract SOS service interface for handling alert operations
abstract class SOSService {
  /// Send SOS alert to backend
  Future<SOSResponse> sendSOSAlert({
    required String sosId,
    required String sosType,
    required Position location,
    Map<String, dynamic>? userInfo,
  });
  
  /// Test backend connectivity
  Future<bool> testConnection();
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
      };

      print('📤 Sending SOS request: $sosData'); // Debug log

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
        print('✅ Backend response: $data'); // Debug log
        return SOSResponse.success(
          messageId: data['messageId']?.toString() ?? data['sosId']?.toString() ?? 'unknown',
          topic: data['topic']?.toString() ?? 'unknown',
          message: data['message']?.toString() ?? 'SOS alert processed successfully',
        );
      } else {
        print('❌ Backend error response: ${response.statusCode} - ${response.body}'); // Debug log
        final errorData = json.decode(response.body);
        return SOSResponse.error(
          error: errorData['error'] ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ SOS Service Exception: $e'); // Debug log
      String errorMessage = 'Failed to send SOS alert';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please check your connection and backend server.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response from server.';
      }
      
      return SOSResponse.error(
        error: errorMessage,
        originalError: e.toString(),
      );
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing backend connection...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.healthEndpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Backend connected: ${data['status']}');
        print('Firebase status: ${data['firebase']}');
        return data['status'] == 'ok';
      }
      
      return false;
    } catch (e) {
      print('❌ Backend connection failed: $e');
      return false;
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