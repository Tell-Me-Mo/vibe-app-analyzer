# Credits & Authentication Setup Guide

This guide will help you set up the credits-based system with Supabase authentication and RevenueCat payments for VibeCheck.

## Overview

The app now includes:
- **Credits System**: 10 free credits on first launch, 5 credits per analysis
- **Authentication**: Sign in with Email, Google, or Apple (powered by Supabase)
- **Payments**: Purchase credit packages via RevenueCat (iOS/Android/Web)
- **User Profiles**: Synced across devices with credit balance

## Technical Stack

- **RevenueCat SDK**: `purchases_flutter: ^9.9.4` (with Flutter Web beta support)
- **Supabase**: `supabase_flutter: ^2.10.3` (latest stable with idempotent initialization)
- **Crypto**: `crypto: ^3.0.6` (for secure Apple Sign In nonce generation)
- **Platform Support**: iOS 11.0+, Android 5.0+, macOS 10.14+, Web (all browsers)

## Supabase Setup

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and anon key

### 2. Create the Profiles Table

Run this SQL in your Supabase SQL editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  credits INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  has_seen_welcome BOOLEAN NOT NULL DEFAULT FALSE
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 3. Configure Authentication Providers

In your Supabase project dashboard:

#### Email Authentication
- Go to Authentication → Providers
- Enable Email provider
- Configure email templates (optional)

#### Google OAuth
1. Go to Authentication → Providers → Google
2. Enable Google provider
3. Follow Supabase's guide to set up Google OAuth:
   - Create a Google Cloud project
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs from Supabase
4. Add your Google Client ID and Secret to Supabase

#### Apple Sign In
1. Go to Authentication → Providers → Apple
2. Enable Apple provider
3. Follow Supabase's guide to set up Apple Sign In:
   - Create an Apple Developer account
   - Register your App ID in Apple Developer Console
   - Create a Services ID (this will be your OAuth Client ID)
   - Generate a key for Sign in with Apple
   - Configure the redirect URL: `https://<your-project-ref>.supabase.co/auth/v1/callback`
4. Add your Apple credentials to Supabase dashboard

**Security Note**: Our implementation uses cryptographically secure nonce generation with SHA-256 hashing, as required by Supabase and Apple for preventing replay attacks. This is implemented in `lib/services/auth_service.dart`.

### 4. Update .env File

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## RevenueCat Setup

### 1. Create a RevenueCat Account

1. Go to [https://www.revenuecat.com](https://www.revenuecat.com)
2. Create a new account and project
3. Give your project a name (e.g., "VibeCheck")

### 2. Configure Products

Create the following products in RevenueCat dashboard:

| Product ID | Name | Type | Credits | Price |
|------------|------|------|---------|-------|
| `starter_pack` | Starter Pack | Non-consumable | 20 | $4.99 |
| `popular_pack` | Popular Pack | Non-consumable | 50 | $9.99 |
| `professional_pack` | Professional Pack | Non-consumable | 120 | $19.99 |
| `enterprise_pack` | Enterprise Pack | Non-consumable | 300 | $39.99 |

**Important**: The product IDs must match exactly as shown above (they're referenced in `lib/models/credit_package.dart:87-96`).

### 3. Platform-Specific Setup

#### iOS/macOS Setup

**Step 1: App Store Connect Configuration**
1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to your app → Features → In-App Purchases
3. Create 4 new in-app purchases (Non-Consumable):
   - Product ID: `starter_pack`, Price: $4.99
   - Product ID: `popular_pack`, Price: $9.99
   - Product ID: `professional_pack`, Price: $19.99
   - Product ID: `enterprise_pack`, Price: $39.99
4. Fill in the required metadata for each product
5. Submit for review

**Step 2: Xcode Configuration**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" and add "In-App Purchase"
5. Ensure your Bundle Identifier matches App Store Connect

**Step 3: RevenueCat Integration**
1. In RevenueCat dashboard, go to Project Settings → Apps
2. Click "Add App" → iOS
3. Enter your Bundle ID
4. Select "App Store"
5. Enter your App Store Connect credentials (App-Specific Shared Secret)
6. Copy your **iOS API Key** (format: `appl_xxxxxxxxxxxxx`)

**Step 4: Minimum iOS Version**
Ensure `ios/Podfile` has:
```ruby
platform :ios, '11.0'
```

#### Android Setup

**Step 1: Google Play Console Configuration**
1. Log in to [Google Play Console](https://play.google.com/console)
2. Select your app → Monetize → In-app products
3. Create 4 new managed products:
   - Product ID: `starter_pack`, Price: $4.99
   - Product ID: `popular_pack`, Price: $9.99
   - Product ID: `professional_pack`, Price: $19.99
   - Product ID: `enterprise_pack`, Price: $39.99
4. Activate each product

**Step 2: Android Manifest Configuration** ✅
The following has been pre-configured in `android/app/src/main/AndroidManifest.xml`:
- ✅ `BILLING` permission added (line 3)
- ✅ `launchMode` set to `singleTop` (line 9)

**Step 3: RevenueCat Integration**
1. In RevenueCat dashboard, go to Project Settings → Apps
2. Click "Add App" → Android
3. Enter your Package Name (e.g., `com.vibecheck.app`)
4. Select "Google Play"
5. Upload your Google Play service credentials JSON
6. Copy your **Android API Key** (format: `goog_xxxxxxxxxxxxx`)

#### Web Setup (Beta)

**Step 1: Stripe Account**
1. Create a [Stripe](https://stripe.com) account if you don't have one
2. Complete account verification
3. Get your Stripe API keys from the dashboard

**Step 2: RevenueCat Web Billing**
1. In RevenueCat dashboard, go to Project Settings → Apps
2. Click "Add App" → Web
3. Connect your Stripe account
4. Configure your products in the Web Billing section
5. Copy your **Web API Key** (format: `rcb_xxxxxxxxxxxxx` for production or `rcb_sb_xxxxxxxxxxxxx` for sandbox)

**Important**: Web API keys have a specific format:
- Production: `rcb_xxxxxxxxxxxxx`
- Sandbox: `rcb_sb_xxxxxxxxxxxxx`

**Step 3: Stripe Product Configuration**
Create corresponding products in Stripe with the same pricing:
- starter_pack: $4.99
- popular_pack: $9.99
- professional_pack: $19.99
- enterprise_pack: $39.99

### 4. Update .env File

Create or update your `.env` file in the project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# RevenueCat API Keys
# iOS/macOS: appl_xxxxxxxxxxxxx
REVENUECAT_API_KEY_IOS=appl_your_ios_key_here

# Android: goog_xxxxxxxxxxxxx
REVENUECAT_API_KEY_ANDROID=goog_your_android_key_here

# Web: rcb_xxxxxxxxxxxxx (production) or rcb_sb_xxxxxxxxxxxxx (sandbox)
REVENUECAT_API_KEY_WEB=rcb_your_web_key_here
```

**Security Note**: Never commit the `.env` file to version control. It's already in `.gitignore`.

## Credit Packages

The app includes 4 pre-configured credit packages:

1. **Starter Pack** - 20 credits for $4.99
2. **Popular Pack** - 50 credits for $9.99 (20% savings) ⭐
3. **Professional Pack** - 120 credits for $19.99 (35% savings)
4. **Enterprise Pack** - 300 credits for $39.99 (50% savings)

Each analysis costs 5 credits.

## User Flow

### First Time Users (Guest)
1. Open app → See welcome popup with 10 free credits
2. Can perform 2 analyses (10 credits ÷ 5 per analysis)
3. After using credits, prompted to sign in to purchase more

### Authenticated Users
1. Sign in with Email/Google/Apple
2. Credits synced to profile
3. Purchase credit packages
4. Credits synced across all devices

## Features Implemented

### UI Components
- ✅ Welcome popup on first launch
- ✅ Credits indicator on main page (clickable)
- ✅ Login/Profile button in top-right corner
- ✅ Sign in/Sign up forms with social auth
- ✅ Profile page with user info and credits
- ✅ Credit packages selection page

### Services
- ✅ Credits service with local storage
- ✅ Authentication service (Supabase)
- ✅ Payment service (RevenueCat)
- ✅ User profile service
- ✅ Credit consumption on analysis

### Security
- ✅ Encrypted local storage for sensitive data
- ✅ Row-level security on Supabase
- ✅ Secure authentication flows
- ✅ PCI-compliant payments via RevenueCat/Stripe

## Testing

### Local Testing (Guest Mode)
1. Run the app
2. Welcome popup should appear
3. Check credits indicator shows 10 credits
4. Try to analyze - should consume 5 credits
5. After 2 analyses, should prompt to purchase

### Authentication Testing
1. Click "Sign In" button
2. Test email sign up/sign in
3. Test Google sign in (requires Google OAuth setup)
4. Test Apple sign in (requires Apple Developer account)
5. Verify profile page shows correct info
6. Sign out and sign back in - credits should persist

### Payment Testing
1. Sign in
2. Go to credits page (click credit indicator or "Buy More Credits")
3. Test purchasing a package (use RevenueCat sandbox mode)
4. Verify credits are added after purchase

## Platform-Specific Build Instructions

### iOS/macOS
```bash
# Install dependencies
cd ios && pod install && cd ..

# Run on iOS
flutter run -d ios

# Build for release
flutter build ios --release
```

### Android
```bash
# Run on Android
flutter run -d android

# Build for release
flutter build apk --release
# or
flutter build appbundle --release
```

### Web
```bash
# Run on Web
flutter run -d chrome

# Build for production
flutter build web --release
```

## Troubleshooting

### Supabase Connection Issues
- ✅ Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
- ✅ Check that `.env` file is loaded in `lib/main.dart`
- ✅ Ensure Supabase project is not paused (check dashboard)
- ✅ Check network connectivity
- ✅ Review Supabase logs in dashboard

### Authentication Failures
- ✅ Check Supabase auth logs in dashboard
- ✅ Verify OAuth credentials are correct
- ✅ Ensure redirect URLs are properly configured
- ✅ For Google Sign In: Verify OAuth client ID
- ✅ For Apple Sign In: Check Services ID and key configuration

### RevenueCat Payment Issues

**iOS Specific:**
- ✅ Verify "In-App Purchase" capability is enabled in Xcode
- ✅ Ensure Bundle ID matches App Store Connect
- ✅ Check App Store Connect for product status (must be "Ready to Submit")
- ✅ Test with sandbox account in iOS Settings
- ✅ Verify App-Specific Shared Secret is configured

**Android Specific:**
- ✅ Verify `BILLING` permission is in `AndroidManifest.xml`
- ✅ Ensure Package Name matches Google Play Console
- ✅ Check Google Play Console for product status (must be "Active")
- ✅ Upload service account JSON to RevenueCat
- ✅ Test with Google Play Console test account

**Web Specific:**
- ✅ Verify Web API key format (`rcb_` prefix)
- ✅ Check Stripe webhook configuration
- ✅ Ensure Stripe products match RevenueCat configuration
- ✅ Test in sandbox mode first (`rcb_sb_` key)
- ✅ Check browser console for errors

**General:**
- ✅ Verify RevenueCat API keys in `.env`
- ✅ Check RevenueCat dashboard → Customer History for transaction logs
- ✅ Ensure products are properly configured with matching IDs
- ✅ Test in sandbox/test mode before production
- ✅ Check `lib/models/credit_package.dart` for correct product ID mapping

### Product ID Mismatch
If credits are not granted after purchase:
1. Check RevenueCat dashboard for the actual product identifier used
2. Verify it matches one of the IDs in `lib/models/credit_package.dart:87-96`
3. Add any alternative product ID formats to the mapping if needed

### Flutter Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get

# iOS specific
cd ios && pod install && cd ..

# Regenerate platform files
flutter create .
```

## Testing Checklist

### Pre-Production Testing

- [ ] **Guest Mode**
  - [ ] Welcome popup appears on first launch
  - [ ] 10 credits displayed in indicator
  - [ ] Can perform 2 analyses (consumes 10 credits)
  - [ ] Insufficient credits dialog appears after 2 analyses

- [ ] **Authentication**
  - [ ] Email sign up works
  - [ ] Email sign in works
  - [ ] Google Sign In works (if configured)
  - [ ] Apple Sign In works (if configured)
  - [ ] Profile page displays user info
  - [ ] Sign out works

- [ ] **Payments (Sandbox/Test)**
  - [ ] iOS: Test with sandbox account
  - [ ] Android: Test with Google Play test account
  - [ ] Web: Test with Stripe test mode
  - [ ] Credits are added after purchase
  - [ ] Credits sync to database for authenticated users
  - [ ] Purchase history appears in RevenueCat dashboard

- [ ] **Cross-Platform Sync**
  - [ ] Sign in on Device A
  - [ ] Purchase credits on Device A
  - [ ] Sign in on Device B with same account
  - [ ] Credits appear on Device B

## Notes

- ✅ Credits never expire
- ✅ Minimum purchase is 20 credits ($4.99)
- ✅ Guest users get 10 free credits (2 analyses) without signing in
- ✅ Authenticated users can purchase credits and sync across all devices
- ✅ RevenueCat free tier: $0-10k monthly tracked revenue
- ✅ Product IDs are centrally managed in `lib/models/credit_package.dart`
- ✅ All platform configurations are complete (Android permissions, iOS capabilities)

## Support & Resources

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **RevenueCat Flutter Guide**: https://www.revenuecat.com/docs/getting-started/installation/flutter
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Web Support**: https://docs.flutter.dev/platform-integration/web
