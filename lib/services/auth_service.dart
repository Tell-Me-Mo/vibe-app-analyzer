import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import '../models/user_profile.dart';
import 'credits_service.dart';

/// Authentication service using Supabase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<UserProfile?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
        },
      );

      if (response.user != null) {
        // Create user profile with initial credits
        return await _createUserProfile(
          user: response.user!,
          displayName: displayName,
        );
      }

      return null;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await _getUserProfile(response.user!.id);
      }

      return null;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Check platform support
      if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
        // Initialize Google Sign In (required in v7.0.0+)
        await _googleSignIn.initialize();

        // Authenticate user interactively
        final googleUser = await _googleSignIn.authenticate();

        // Get authentication tokens
        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          throw AuthException('Google sign in failed: Missing ID token');
        }

        // Get access token via authorization (required for Supabase)
        final scopes = <String>[];
        final authorization = await googleUser.authorizationClient.authorizationForScopes(scopes);
        final accessToken = authorization?.accessToken;

        if (accessToken == null) {
          throw AuthException('Google sign in failed: Missing access token');
        }

        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        if (response.user != null) {
          // Check if profile exists, create if not
          var profile = await _getUserProfile(response.user!.id);
          profile ??= await _createUserProfile(
            user: response.user!,
            displayName: googleUser.displayName,
            photoUrl: googleUser.photoUrl,
          );
          return profile;
        }
      } else {
        // Desktop flow using OAuth
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'vibecheck://callback',
        );
      }

      return null;
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<UserProfile?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        // Generate secure nonce for Apple Sign In (required for security)
        final rawNonce = _generateNonce();
        final hashedNonce = _hashNonce(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce, // Use hashed nonce for the request
        );

        final idToken = appleCredential.identityToken;
        if (idToken == null) {
          throw AuthException('Apple sign in failed: Missing token');
        }

        // Use raw nonce (not hashed) for signInWithIdToken
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce, // Pass raw nonce to Supabase
        );

        if (response.user != null) {
          // Check if profile exists, create if not
          var profile = await _getUserProfile(response.user!.id);
          if (profile == null) {
            String? displayName;
            if (appleCredential.givenName != null ||
                appleCredential.familyName != null) {
              displayName =
                  '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                      .trim();
            }

            profile = await _createUserProfile(
              user: response.user!,
              displayName: displayName,
            );
          }
          return profile;
        }
      } else {
        // Web or other platforms: use OAuth flow
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kIsWeb ? null : 'vibecheck://callback',
        );
      }

      return null;
    } catch (e) {
      throw AuthException('Apple sign in failed: $e');
    }
  }

  /// Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Hash the nonce using SHA-256
  String _hashNonce(String nonce) {
    final bytes = utf8.encode(nonce);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      // Clear local credits
      await CreditsService().resetCredits();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  /// Create user profile in database
  Future<UserProfile> _createUserProfile({
    required User user,
    String? displayName,
    String? photoUrl,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName ?? user.userMetadata?['display_name'],
      photoUrl: photoUrl ?? user.userMetadata?['avatar_url'],
      credits: CreditsService.initialCredits,
      createdAt: now,
      updatedAt: now,
      hasSeenWelcome: false,
    );

    // Save to Supabase
    await _supabase.from('profiles').upsert(profile.toJson());

    // Sync credits locally
    await CreditsService().syncFromProfile(profile);

    return profile;
  }

  /// Get user profile from database
  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);

      // Sync credits locally
      await CreditsService().syncFromProfile(profile);

      return profile;
    } catch (e) {
      return null;
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return await _getUserProfile(currentUser!.id);
  }

  /// Update user profile
  Future<UserProfile> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (currentUser == null) {
      throw AuthException('No user signed in');
    }

    final profile = await getCurrentUserProfile();
    if (profile == null) {
      throw AuthException('Profile not found');
    }

    final updatedProfile = profile.copyWith(
      displayName: displayName ?? profile.displayName,
      photoUrl: photoUrl ?? profile.photoUrl,
      updatedAt: DateTime.now(),
    );

    await _supabase.from('profiles').update(updatedProfile.toJson()).eq(
          'id',
          currentUser!.id,
        );

    return updatedProfile;
  }

  /// Update user credits in database
  Future<void> updateCredits(int credits) async {
    if (currentUser == null) return;

    await _supabase.from('profiles').update({
      'credits': credits,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);

    // Sync locally
    await CreditsService().setCredits(credits);
  }

  /// Mark welcome as seen in database
  Future<void> markWelcomeAsSeen() async {
    if (currentUser == null) {
      // Guest user
      await CreditsService().markWelcomeAsSeen();
      return;
    }

    await _supabase.from('profiles').update({
      'has_seen_welcome': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);

    await CreditsService().markWelcomeAsSeen();
  }
}

/// Custom exception for auth errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current user profile
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  // Listen to auth state changes
  await for (final authState in authService.authStateChanges) {
    if (authState.session != null) {
      yield await authService.getCurrentUserProfile();
    } else {
      yield null;
    }
  }
});

/// Provider for auth state
final authStateProvider = StreamProvider<bool>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  await for (final authState in authService.authStateChanges) {
    yield authState.session != null;
  }
});
