import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../core/config/supabase_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient? _supabase;
  GoogleSignIn? _googleSignIn;

  SupabaseClient get supabase => _supabase!;
  
  User? get currentUser => _supabase?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        print('Warning: Supabase not configured. Authentication features will be disabled.');
      }
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    _supabase = Supabase.instance.client;
    
    _googleSignIn = GoogleSignIn(
      serverClientId: '', // Will need to be configured
    );
  }

  Stream<AuthState> get authStateChanges {
    if (_supabase == null) {
      return Stream.value(const AuthState(AuthChangeEvent.signedOut, null));
    }
    return _supabase!.auth.onAuthStateChange;
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (_supabase == null) {
      throw Exception('Supabase not initialized');
    }

    final response = await _supabase!.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );

    // Profile creation is handled by database trigger
    // No need to manually create profile here

    return response;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_supabase == null) {
      throw Exception('Supabase not initialized');
    }

    return await _supabase!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    if (_supabase == null) {
      throw Exception('Supabase not initialized');
    }

    if (_googleSignIn == null) {
      throw Exception('Google Sign In not configured');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await _supabase!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      // Profile creation is handled by database trigger
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple() async {
    if (_supabase == null) {
      throw Exception('Supabase not initialized');
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _supabase!.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      // Profile creation is handled by database trigger
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_supabase == null) return;
    
    await _googleSignIn?.signOut();
    await _supabase!.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    if (_supabase == null) {
      throw Exception('Supabase not initialized');
    }

    await _supabase!.auth.resetPasswordForEmail(email);
  }

  Future<void> _createUserProfile(User user) async {
    if (_supabase == null) return;

    try {
      final existingProfile = await _supabase!
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        await _supabase!.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] ?? 
                      user.userMetadata?['name'] ?? 
                      user.email?.split('@').first,
          'is_premium': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_supabase == null || currentUser == null) return null;

    try {
      final response = await _supabase!
          .from('profiles')
          .select('*')
          .eq('id', currentUser!.id)
          .single();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_supabase == null || currentUser == null) return;

    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase!
          .from('profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  Future<void> updateSubscriptionStatus(bool isPremium) async {
    if (_supabase == null || currentUser == null) return;

    await updateUserProfile({'is_premium': isPremium});
  }

  bool isSupabaseConfigured() => SupabaseConfig.isConfigured;
}