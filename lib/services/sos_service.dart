import '../models/sos_alert.dart';

/// Abstract SOS service interface for handling alert operations
abstract class SOSService {
  /// Send SOS alert to backend
  Future<bool> sendSOSAlert(SOSAlert alert);
  
  /// Update existing SOS alert (for modifications)
  Future<bool> updateSOSAlert(String alertId, String? newMessage);
  
  /// Stop/cancel active SOS alert
  Future<bool> stopSOSAlert(String alertId);
  
  /// Get status of sent alert
  Future<Map<String, dynamic>?> getAlertStatus(String alertId);
}

/// HTTP-based implementation for communicating with Go backend
class HTTPSOSService implements SOSService {
  // TODO: Implement HTTP client logic for backend communication
  
  @override
  Future<bool> sendSOSAlert(SOSAlert alert) async {
    // Send POST request to /api/sos endpoint
    throw UnimplementedError('Send SOS alert implementation pending');
  }

  @override
  Future<bool> updateSOSAlert(String alertId, String? newMessage) async {
    // Send PUT request to update alert
    throw UnimplementedError('Update SOS alert implementation pending');
  }

  @override
  Future<bool> stopSOSAlert(String alertId) async {
    // Send DELETE request to stop alert
    throw UnimplementedError('Stop SOS alert implementation pending');
  }

  @override
  Future<Map<String, dynamic>?> getAlertStatus(String alertId) async {
    // Send GET request to check alert status
    throw UnimplementedError('Get alert status implementation pending');
  }
}