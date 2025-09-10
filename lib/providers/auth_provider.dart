import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/user_session_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool hasCompletedOnboarding;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? userProfile;

  const AuthState({
    this.isAuthenticated = false,
    this.hasCompletedOnboarding = false,
    this.isLoading = false,
    this.error,
    this.userProfile,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userProfile,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final UserSessionService _sessionService = UserSessionService();

  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _sessionService.initialize();
      
      final isSessionValid = await _sessionService.isSessionValid();
      final hasCompletedOnboarding = _sessionService.hasCompletedOnboarding;
      
      Map<String, dynamic>? userProfile;
      if (isSessionValid && _authService.isAuthenticated) {
        userProfile = await _authService.getUserProfile();
      }
      
      state = AuthState(
        isAuthenticated: isSessionValid,
        hasCompletedOnboarding: hasCompletedOnboarding,
        isLoading: false,
        userProfile: userProfile,
      );
      
      if (kDebugMode) {
        print('Auth state initialized: ${state.isAuthenticated}, onboarding: ${state.hasCompletedOnboarding}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth state: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (_authService.isSupabaseConfigured()) {
        await _authService.signInWithEmail(email: email, password: password);
        final userProfile = await _authService.getUserProfile();
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userProfile: userProfile,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (_authService.isSupabaseConfigured()) {
        final response = await _authService.signUpWithEmail(
          email: email,
          password: password,
          fullName: fullName,
        );
        
        if (kDebugMode) {
          print('Signup response - User: ${response.user?.id}, Session: ${response.session?.accessToken != null}');
        }
        
        // Only set as authenticated if user is confirmed
        // For email confirmation flow, user will be null until email is confirmed
        if (response.user != null && response.session != null) {
          final userProfile = await _authService.getUserProfile();
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            userProfile: userProfile,
          );
        } else {
          // Email confirmation required - user exists but no session yet
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
          );
        }
        
        return response;
      } else {
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (_authService.isSupabaseConfigured()) {
        await _authService.signInWithGoogle();
        final userProfile = await _authService.getUserProfile();
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userProfile: userProfile,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (_authService.isSupabaseConfigured()) {
        await _authService.signInWithApple();
        final userProfile = await _authService.getUserProfile();
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userProfile: userProfile,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _sessionService.signOut();
      state = const AuthState();
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      state = const AuthState();
    }
  }

  Future<void> completeOnboarding() async {
    await _sessionService.markOnboardingCompleted();
    state = state.copyWith(hasCompletedOnboarding: true);
    
    if (kDebugMode) {
      print('Onboarding completed');
    }
  }

  Future<void> resetOnboarding() async {
    await _sessionService.resetOnboardingState();
    state = state.copyWith(hasCompletedOnboarding: false);
    
    if (kDebugMode) {
      print('Onboarding reset');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (_authService.isSupabaseConfigured()) {
        await _authService.resetPassword(email);
      } else {
        throw Exception('Password reset not available in demo mode');
      }
    } catch (e) {
      rethrow;
    }
  }

  String get initialRoute {
    if (state.isLoading) return '/';
    
    if (!state.hasCompletedOnboarding) {
      return '/onboarding';
    }
    
    if (!state.isAuthenticated) {
      return '/login';
    }
    
    return '/home';
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});