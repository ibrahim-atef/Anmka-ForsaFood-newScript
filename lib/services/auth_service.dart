import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service class to handle Firebase Authentication operations
/// Specifically for email verification functionality
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if the current user's email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.emailVerified;
  }

  /// Send email verification link to the current user
  /// Returns true if successful, false otherwise
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('AuthService: No user logged in');
        return false;
      }

      if (user.emailVerified) {
        debugPrint('AuthService: Email already verified');
        return true;
      }

      await user.sendEmailVerification();
      debugPrint('AuthService: Verification email sent to ${user.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Firebase error sending verification email: ${e.code} - ${e.message}');
      
      // Handle specific error codes
      if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Please try again later.');
      } else if (e.code == 'user-not-found') {
        throw Exception('User not found. Please register again.');
      }
      
      throw Exception('Failed to send verification email: ${e.message}');
    } catch (e) {
      debugPrint('AuthService: Error sending verification email: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Reload the current user to get the latest email verification status
  /// This is useful after the user has verified their email
  Future<bool> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      // Get the updated user after reload
      final updatedUser = _auth.currentUser;
      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('AuthService: Error reloading user: $e');
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('AuthService: User signed out successfully');
    } catch (e) {
      debugPrint('AuthService: Error signing out: $e');
      rethrow;
    }
  }

  /// Check if email verification is required for the current user
  /// Returns true if user exists and email is not verified
  bool requiresEmailVerification() {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    // Only email/password providers require verification
    // Google and Apple sign-ins are pre-verified
    final isEmailProvider = user.providerData.any(
      (info) => info.providerId == 'password'
    );
    
    return isEmailProvider && !user.emailVerified;
  }

  /// Get the user's email address
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Wait for email verification with timeout
  /// Polls Firebase every few seconds to check verification status
  /// Returns true if verified within timeout, false otherwise
  Future<bool> waitForEmailVerification({
    Duration timeout = const Duration(minutes: 5),
    Duration checkInterval = const Duration(seconds: 3),
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      await reloadUser();
      
      if (isEmailVerified()) {
        debugPrint('AuthService: Email verified!');
        return true;
      }
      
      await Future.delayed(checkInterval);
    }
    
    debugPrint('AuthService: Email verification timeout');
    return false;
  }
}

