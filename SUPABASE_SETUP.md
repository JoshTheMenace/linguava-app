# Supabase Setup Instructions

## 1. Create Supabase Project

1. Go to [Supabase](https://supabase.com) and create a new project
2. Note your project URL and anon key from the project settings

## 2. Configure Supabase in Your App

1. Open `lib/core/config/supabase_config.dart`
2. Replace the empty strings with your actual Supabase credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static bool get isConfigured => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
```

## 3. Set Up Database Schema

1. Open your Supabase project dashboard
2. Go to the SQL Editor
3. Run the SQL script from `supabase_schema.sql` to create the required tables and policies

**Important Notes for RLS (Row Level Security):**
- The database trigger automatically creates user profiles when new users sign up
- Make sure the trigger function `handle_new_user()` is created with `SECURITY DEFINER` to bypass RLS
- If you encounter "new row violates row-level security policy" errors, verify the trigger is properly created

## 4. Configure Authentication Providers

### Google Sign-In Setup

1. **Create Google Project:**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select existing one
   - Enable Google+ API

2. **Configure OAuth 2.0:**
   - Go to Credentials section
   - Create OAuth 2.0 Client ID
   - For Android: Add your SHA-1 fingerprint
   - For iOS: Add your bundle identifier

3. **Update Supabase:**
   - In Supabase dashboard, go to Authentication > Settings
   - Enable Google provider
   - Add your Google OAuth credentials

4. **Update App:**
   - In `lib/services/auth_service.dart`, update the `serverClientId` in GoogleSignIn initialization

### Apple Sign-In Setup

1. **Configure in Apple Developer:**
   - Enable Sign in with Apple for your app ID
   - Configure service ID for web authentication

2. **Update Supabase:**
   - In Supabase dashboard, enable Apple provider
   - Add your service ID and other required credentials

## 5. Configure Google Play Subscriptions

### Google Play Console Setup

1. **Create Subscription Products:**
   - Go to Google Play Console
   - Navigate to Monetize > Products > Subscriptions
   - Create subscription products with IDs:
     - `premium_monthly`
     - `premium_yearly`

2. **Configure Play Billing:**
   - Set up Google Play Billing in your app
   - Configure subscription products

3. **Update Product IDs:**
   - In `lib/services/subscription_service.dart`, verify the product IDs match your Google Play Console setup

### Server-Side Verification (Optional but Recommended)

For production, implement server-side purchase verification:

1. Set up Google Play Developer API
2. Create a cloud function or server endpoint to verify purchases
3. Update the `_verifyPurchaseWithServer` method in `SubscriptionService`

## 6. Configure Email Authentication Settings

### Enable Email Confirmation

1. **In Supabase Dashboard:**
   - Go to Authentication > Settings
   - Under "User Signups" section:
     - Enable "Email confirmations"
     - Set "Site URL" to your app's deep link scheme (e.g., `linguava://auth`)
     - Set "Redirect URLs" to include your app's deep link scheme

2. **Configure Email Templates:**
   - Go to Authentication > Email Templates
   - Customize the "Confirm signup" template
   - Make sure the confirmation link uses your app's deep link scheme

### Deep Link Configuration

Your email confirmation URLs should redirect to your app instead of localhost.

**For Development:**
- Site URL: `linguava://auth`
- Redirect URLs: `linguava://auth/callback, http://localhost:3000/auth/callback`

**For Production:**
- Site URL: `https://yourdomain.com`
- Redirect URLs: `https://yourdomain.com/auth/callback, linguava://auth/callback`

## 7. Platform-Specific Configuration

### Android Configuration

1. **Add to `android/app/build.gradle`:**

```gradle
dependencies {
    implementation 'com.android.billingclient:billing:5.0.0'
}
```

2. **Add intent filter to `android/app/src/main/AndroidManifest.xml`:**

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- Standard Flutter launch intent -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep link for auth callback -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="linguava" android:host="auth" />
    </intent-filter>
</activity>
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>supabase-login</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>linguava</string>
        </array>
    </dict>
</array>
```

## 7. Test the Implementation

1. Run `flutter pub get` to install dependencies
2. Build and run the app
3. Test authentication flows:
   - Email/password signup and login
   - Google Sign-In
   - Apple Sign-In (iOS only)
4. Test subscription functionality:
   - Purchase flow
   - Restore purchases
   - Subscription status sync

## Security Notes

- Never commit actual credentials to version control
- Use environment variables or secure storage for production
- Implement proper error handling and user feedback
- Set up proper Row Level Security policies in Supabase
- Validate purchases server-side in production

## Troubleshooting

### Common Issues:

1. **Supabase not configured**: Check that URLs and keys are properly set
2. **Social auth fails**: Verify OAuth setup in respective platforms
3. **Purchases not working**: Check Google Play Console configuration
4. **Database errors**: Verify RLS policies are properly configured

### Debugging Tips:

- Enable debug mode to see detailed logs
- Check Supabase dashboard for auth logs
- Use Android/iOS emulators for testing
- Test with real devices for in-app purchases