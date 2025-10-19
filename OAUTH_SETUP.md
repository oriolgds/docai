# OAuth Setup Guide for DocAI

## Changes Made

### 1. GitHub & Discord OAuth Authentication
- Added `signInWithGitHub()` and `signInWithDiscord()` methods in `SupabaseService`
- Added GitHub and Discord login buttons in the login screen
- Both use Supabase's OAuth flow with proper redirect handling

### 2. Twitter/X Link in Profile
- Added a "Follow Us" section in the profile screen
- Links to https://x.com/docaiapp
- Opens in external browser

### 3. Deep Link Handling Improvements
- Enhanced OAuth callback handling in `main.dart`
- OAuth providers (GitHub, Discord, Google) now bypass email verification
- Added debug logging for troubleshooting
- Fixed navigation flow after OAuth authentication

## Configuration Required

### Step 1: Configure OAuth Providers in Supabase

#### GitHub OAuth Setup
1. Go to your Supabase project dashboard
2. Navigate to **Authentication** > **Providers**
3. Enable **GitHub** provider
4. **IMPORTANT**: In the GitHub provider settings in Supabase, set the **Redirect URL** to: `docai://auth`
5. Create a GitHub OAuth App:
   - Go to https://github.com/settings/developers
   - Click "New OAuth App"
   - **Application name**: DocAI
   - **Homepage URL**: Your app's website
   - **Authorization callback URL**: `https://[YOUR-SUPABASE-PROJECT].supabase.co/auth/v1/callback`
6. Copy the **Client ID** and **Client Secret** to Supabase

#### Discord OAuth Setup
1. In Supabase dashboard, enable **Discord** provider
2. **IMPORTANT**: In the Discord provider settings in Supabase, set the **Redirect URL** to: `docai://auth`
3. Create a Discord Application:
   - Go to https://discord.com/developers/applications
   - Click "New Application"
   - Name it "DocAI"
   - Go to **OAuth2** section
   - Add redirect URL: `https://[YOUR-SUPABASE-PROJECT].supabase.co/auth/v1/callback`
4. Copy the **Client ID** and **Client Secret** to Supabase

### Step 2: Configure Deep Links

The app uses the redirect URL: `docai://auth`

#### For Android (android/app/src/main/AndroidManifest.xml)
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="docai" android:host="auth" />
</intent-filter>
```

#### For iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>docai</string>
        </array>
    </dict>
</array>
```

#### For Web (web/index.html)
Add to the `<head>` section:
```html
<meta name="apple-mobile-web-app-capable" content="yes">
<link rel="manifest" href="manifest.json">
```

### Step 3: Test the OAuth Flow

1. **Run the app** in debug mode to see console logs
2. **Click GitHub or Discord button** on login screen
3. **Check debug console** for these messages:
   - "Handling deep link: ..."
   - "Handling auth callback..."
   - "Session established from URL"
   - "Current user after OAuth: [email]"
   - "User provider: github/discord"
   - "OAuth provider detected, navigating to dashboard"

4. **If it doesn't work**, check:
   - Deep link is properly configured in your platform's manifest
   - Supabase OAuth redirect URL matches your project
   - Console logs show the deep link being received

## How It Works

### OAuth Flow
1. User clicks GitHub/Discord button
2. App opens browser with Supabase OAuth URL
3. User authorizes on GitHub/Discord
4. OAuth provider redirects to Supabase
5. Supabase redirects to `docai://auth#access_token=...&refresh_token=...`
6. App receives deep link
7. `_handleDeepLink()` detects tokens in fragment/query
8. `_handleAuthCallback()` extracts session from URL
9. Checks user provider (github/discord/google)
10. OAuth users bypass email verification
11. Navigates to dashboard

### Key Differences from Email/Password
- OAuth users don't need email verification
- Provider is checked via `user.appMetadata['provider']`
- Navigation happens via deep link callback, not immediately after button click

## Troubleshooting

### Issue: "Receiving email-verified link instead of auth callback"
**Cause**: Supabase OAuth provider is using the wrong redirect URL

**Logs showing**:
```
handleIntent: (Data) docai://email-verified?code=...
Deep link host: email-verified
```

**Solution**:
1. Go to Supabase Dashboard → **Authentication** → **Providers**
2. Click on **GitHub** or **Discord** provider
3. Look for **"Redirect URL"** or **"Site URL"** field
4. Change it from the default to: `docai://auth`
5. Save the settings
6. Try OAuth login again

This is the MOST COMMON issue. Supabase defaults to using the email verification URL for all redirects unless you specifically set the OAuth redirect URL.

### Issue: "Account created but nothing happens"
**Cause**: Deep link not being received or handled properly

**Solutions**:
1. Check deep link configuration in AndroidManifest.xml or Info.plist
2. Verify redirect URL in Supabase OAuth provider settings is `docai://auth`
3. Check console logs for deep link reception
4. Try closing and reopening the app after OAuth

### Issue: "Stays on login screen after OAuth"
**Cause**: Email verification check blocking OAuth users

**Solution**: Already fixed! OAuth providers now bypass email verification check.

### Issue: "Browser opens but doesn't redirect back"
**Cause**: Redirect URL mismatch

**Solutions**:
1. Ensure Supabase OAuth callback URL is correct
2. Check that deep link scheme is registered
3. Test deep link manually: `adb shell am start -W -a android.intent.action.VIEW -d "docai://auth" com.yourpackage`

## Debug Commands

### Test Deep Link (Android)
```bash
adb shell am start -W -a android.intent.action.VIEW -d "docai://auth#access_token=test&refresh_token=test" com.yourpackage.docai
```

### View Logs (Android)
```bash
adb logcat | grep -i "flutter\|docai\|auth"
```

### Test Deep Link (iOS)
```bash
xcrun simctl openurl booted "docai://auth#access_token=test&refresh_token=test"
```
