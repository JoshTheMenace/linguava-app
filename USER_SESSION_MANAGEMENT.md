# User Session Management & Onboarding

This document explains the persistent login and onboarding functionality implemented in the Linguava app.

## Features Implemented

### 1. Persistent User Sessions
- **Session Storage**: User login state is stored in SharedPreferences
- **Auto-Login**: Users remain logged in across app restarts
- **Session Validation**: Sessions expire after 30 days of inactivity
- **Cross-Device Sync**: When using Supabase, user data syncs across devices

### 2. Onboarding State Management
- **First Launch Detection**: App detects if user has completed onboarding
- **Skip Onboarding**: Once completed, users go directly to login/home screen
- **Reset Capability**: Onboarding state can be reset for testing

### 3. Smart Routing
- **Dynamic Initial Route**: App determines starting screen based on state
- **Route Protection**: Authenticated routes require login
- **Seamless Navigation**: No authentication prompts for logged-in users

## How It Works

### App Launch Flow
```
App Start
    ↓
Check Onboarding Status
    ↓
Has Completed Onboarding?
    ├─ No → Show Onboarding Screen
    └─ Yes → Check Authentication Status
                ↓
            Is Authenticated?
                ├─ No → Show Login Screen
                └─ Yes → Show Home Screen
```

### User Session Service
The `UserSessionService` manages:
- ✅ Onboarding completion flag
- ✅ User login status
- ✅ User profile data (email, name, premium status)
- ✅ Session validation and expiry
- ✅ Automatic session cleanup on logout

### Authentication Provider
The `AuthProvider` using Riverpod provides:
- ✅ Reactive authentication state
- ✅ Loading states for UI feedback
- ✅ Error handling and user feedback
- ✅ Integration with Supabase and local storage

## Key Files

### Services
- `lib/services/user_session_service.dart` - Session persistence
- `lib/services/auth_service.dart` - Supabase authentication
- `lib/providers/auth_provider.dart` - State management

### Routing
- `lib/core/utils/router_service.dart` - Smart routing logic
- `lib/main.dart` - App initialization

### Screens
- `lib/screens/onboarding/onboarding_screen.dart` - Marks onboarding complete
- `lib/screens/auth/login_screen.dart` - Uses auth provider
- `lib/screens/auth/signup_screen.dart` - Uses auth provider
- `lib/screens/settings/settings_screen.dart` - Logout functionality

## User Experience

### First Time Users
1. See splash screen
2. Go through onboarding (3 screens)
3. Taken to login screen
4. After signup/login, go to home screen
5. **Next app launch**: Skip directly to home screen (if logged in)

### Returning Users
- **Logged in**: Go directly to home screen
- **Logged out**: Go directly to login screen
- **Never seen onboarding**: Start with onboarding

### Authentication States
- **Loading**: Show splash screen
- **Not onboarded**: Show onboarding
- **Not authenticated**: Show login
- **Authenticated**: Show home

## Testing the Implementation

### Test Scenarios
1. **Fresh install**: Should show onboarding → login → home
2. **App restart**: Should skip to appropriate screen based on state
3. **Logout**: Should clear session and return to login
4. **Signup flow**: Should save session and skip onboarding next time
5. **Session expiry**: Should logout user after 30 days

### Debug Options
You can test different states by:
1. Using the settings screen logout button
2. Clearing app data to reset everything
3. Modifying session timeout for testing

## Configuration

### Session Timeout
```dart
const sessionValidityDuration = Duration(days: 30); // In user_session_service.dart
```

### Onboarding Reset
```dart
await UserSessionService().resetOnboardingState();
```

### Clear All Data
```dart
await UserSessionService().clearAllData();
```

## Production Considerations

### Security
- ✅ No sensitive data stored locally
- ✅ Session tokens handled by Supabase
- ✅ Automatic session cleanup
- ✅ Secure authentication flow

### Performance
- ✅ Minimal startup time
- ✅ Efficient state management
- ✅ Smart routing reduces navigation
- ✅ Background session validation

### User Experience
- ✅ Seamless login experience
- ✅ Clear authentication states
- ✅ Proper error handling
- ✅ Intuitive navigation flow

The implementation provides a smooth, secure, and user-friendly authentication experience that works both with and without Supabase configuration.