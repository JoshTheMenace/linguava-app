import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  final AuthService _authService = AuthService();
  SharedPreferences? _prefs;

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyLastLoginTime = 'last_login_time';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    if (_authService.isSupabaseConfigured()) {
      _authService.authStateChanges.listen((authState) {
        _handleAuthStateChange(authState);
      });
      
      if (_authService.isAuthenticated) {
        await _saveUserSession();
      }
    }
  }

  Future<void> _handleAuthStateChange(authState) async {
    if (authState.event == AuthChangeEvent.signedIn && authState.session?.user != null) {
      await _saveUserSession();
    } else if (authState.event == AuthChangeEvent.signedOut) {
      await _clearUserSession();
    }
  }

  Future<void> _saveUserSession() async {
    if (_prefs == null || !_authService.isAuthenticated) return;

    final user = _authService.currentUser!;
    final userProfile = await _authService.getUserProfile();

    await _prefs!.setBool(_keyIsLoggedIn, true);
    await _prefs!.setString(_keyUserEmail, user.email ?? '');
    await _prefs!.setString(_keyUserId, user.id);
    await _prefs!.setString(_keyUserName, userProfile?['full_name'] ?? user.email?.split('@').first ?? '');
    await _prefs!.setBool(_keyIsPremium, userProfile?['is_premium'] ?? false);
    await _prefs!.setString(_keyLastLoginTime, DateTime.now().toIso8601String());

    if (kDebugMode) {
      print('User session saved');
    }
  }

  Future<void> _clearUserSession() async {
    if (_prefs == null) return;

    await _prefs!.setBool(_keyIsLoggedIn, false);
    await _prefs!.remove(_keyUserEmail);
    await _prefs!.remove(_keyUserId);
    await _prefs!.remove(_keyUserName);
    await _prefs!.remove(_keyIsPremium);
    await _prefs!.remove(_keyLastLoginTime);

    if (kDebugMode) {
      print('User session cleared');
    }
  }

  Future<void> markOnboardingCompleted() async {
    if (_prefs == null) return;
    await _prefs!.setBool(_keyOnboardingCompleted, true);
    
    if (kDebugMode) {
      print('Onboarding marked as completed');
    }
  }

  Future<void> resetOnboardingState() async {
    if (_prefs == null) return;
    await _prefs!.setBool(_keyOnboardingCompleted, false);
    
    if (kDebugMode) {
      print('Onboarding state reset');
    }
  }

  bool get hasCompletedOnboarding {
    if (_prefs == null) return false;
    return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
  }

  bool get isLoggedIn {
    if (_prefs == null) return false;
    
    if (_authService.isSupabaseConfigured()) {
      return _authService.isAuthenticated;
    }
    
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }

  String get userEmail {
    if (_prefs == null) return '';
    return _prefs!.getString(_keyUserEmail) ?? '';
  }

  String get userId {
    if (_prefs == null) return '';
    return _prefs!.getString(_keyUserId) ?? '';
  }

  String get userName {
    if (_prefs == null) return '';
    return _prefs!.getString(_keyUserName) ?? '';
  }

  bool get isPremium {
    if (_prefs == null) return false;
    return _prefs!.getBool(_keyIsPremium) ?? false;
  }

  DateTime? get lastLoginTime {
    if (_prefs == null) return null;
    final timeString = _prefs!.getString(_keyLastLoginTime);
    if (timeString == null) return null;
    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserName(String name) async {
    if (_prefs == null) return;
    await _prefs!.setString(_keyUserName, name);
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    if (_prefs == null) return;
    await _prefs!.setBool(_keyIsPremium, isPremium);
  }

  Future<void> signOut() async {
    try {
      if (_authService.isSupabaseConfigured()) {
        await _authService.signOut();
      }
      await _clearUserSession();
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      await _clearUserSession();
    }
  }

  Future<void> clearAllData() async {
    if (_prefs == null) return;
    await _prefs!.clear();
    
    if (kDebugMode) {
      print('All user data cleared');
    }
  }

  Map<String, dynamic> getUserSessionData() {
    return {
      'isLoggedIn': isLoggedIn,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
      'isPremium': isPremium,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
    };
  }

  Future<bool> isSessionValid() async {
    if (!isLoggedIn) return false;
    
    final lastLogin = lastLoginTime;
    if (lastLogin == null) return false;
    
    const sessionValidityDuration = Duration(days: 30);
    final isWithinValidPeriod = DateTime.now().difference(lastLogin) < sessionValidityDuration;
    
    if (!isWithinValidPeriod) {
      await _clearUserSession();
      return false;
    }
    
    if (_authService.isSupabaseConfigured()) {
      return _authService.isAuthenticated;
    }
    
    return true;
  }
}