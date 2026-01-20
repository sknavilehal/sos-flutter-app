class ApiConfig {
  static const String _prodBaseUrl = 'http://139.84.149.99:3000';
  
  // Update this with your ngrok URL when testing on physical device
  static const String _ngrokUrl = 'http://139.84.149.99:3000';
  
  static String get baseUrl {
    // Check if we're in debug mode (development)
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    
    if (isProduction) {
      return _prodBaseUrl;
    }
    
    // For development/testing
    // Change this to _ngrokUrl when testing on physical device
    // Change to _devBaseUrl when testing on simulator/emulator
    return _ngrokUrl;  // Now using ngrok for testing
  }
  
  static String get sosEndpoint => '$baseUrl/api/sos';
  static String get healthEndpoint => '$baseUrl/health';
  
  // Helper method to easily switch to ngrok for testing
  static void useNgrok(String ngrokUrl) {
    // This would require updating the configuration
    // For now, manually update _ngrokUrl above and change baseUrl getter
    print('Update _ngrokUrl to: $ngrokUrl and change baseUrl getter to return _ngrokUrl');
  }
}