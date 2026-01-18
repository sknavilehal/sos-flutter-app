/// Abstract authentication service interface
/// This allows easy switching between Firebase Auth, Google Sign-In, etc.
abstract class AuthService {
  /// Initialize the authentication service
  Future<void> initialize();
  
  /// Get current user ID (Firebase UID or custom identifier)
  String? get currentUserId;
  
  /// Check if user is authenticated
  bool get isAuthenticated;
  
  /// Sign in anonymously (for MVP)
  Future<String?> signInAnonymously();
  
  /// Sign out current user
  Future<void> signOut();
  
  /// Stream of authentication state changes
  Stream<String?> get authStateChanges;
}

/// Firebase implementation of AuthService
class FirebaseAuthService implements AuthService {
  // TODO: Implement Firebase Auth logic
  
  @override
  Future<void> initialize() async {
    // Initialize Firebase Auth
    throw UnimplementedError('Firebase Auth implementation pending');
  }

  @override
  String? get currentUserId => null;

  @override
  bool get isAuthenticated => false;

  @override
  Future<String?> signInAnonymously() async {
    throw UnimplementedError('Anonymous sign-in implementation pending');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('Sign out implementation pending');
  }

  @override
  Stream<String?> get authStateChanges {
    throw UnimplementedError('Auth state changes stream pending');
  }
}