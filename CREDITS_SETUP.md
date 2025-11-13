# Credits & Authentication Setup Guide

This guide will help you set up the credits-based system with Supabase authentication and RevenueCat payments for VibeCheck.

## Overview

The app now includes:
- **Credits System**: 10 free credits on first launch, 5 credits per analysis
- **Authentication**: Sign in with Email, Google, or Apple (powered by Supabase)
- **Payments**: Purchase credit packages via RevenueCat (Web only with Paddle)
- **User Profiles**: Synced across devices with credit balance

## Technical Stack

- **RevenueCat SDK**: `purchases_flutter: ^9.9.4` (with Flutter Web beta support)
- **Supabase**: `supabase_flutter: ^2.10.3` (latest stable with idempotent initialization)
- **Crypto**: `crypto: ^3.0.6` (for secure Apple Sign In nonce generation)
- **Payment Provider**: Paddle (for web payments)
- **Platform Support**: Web (all browsers)

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

### 3. Web Setup with Paddle

**Step 1: Paddle Account**
1. Create a [Paddle](https://www.paddle.com) account if you don't have one
2. Complete account verification and seller onboarding
3. Navigate to the Paddle dashboard
4. Note your Paddle Vendor ID and API credentials

**Step 2: Add Web Billing App in RevenueCat**
1. Log into your [RevenueCat dashboard](https://app.revenuecat.com)
2. Select your project
3. Go to **Apps & providers** (left sidebar)
4. Click **"+ New"** button
5. Select **"Web"** or **"Web Billing"** from the platform options
6. Give your web app a name (e.g., "VibeCheck Web")

**Step 3: Connect Paddle to RevenueCat**
1. In the Web Billing app configuration screen:
   - Select **Paddle** as your payment provider
   - Enter your **Paddle Vendor ID**
   - Add your **Paddle API credentials** (Auth Code or API Key)
   - Copy the webhook URL provided by RevenueCat
2. Go back to your Paddle dashboard:
   - Navigate to Developer Tools → Webhooks
   - Add the RevenueCat webhook URL
   - Enable necessary webhook events (subscriptions, payments, etc.)
3. Choose your environment:
   - **Sandbox** for testing
   - **Production** for live payments

**Step 4: Get Your RevenueCat Public API Keys**

After creating your Web Billing app, RevenueCat automatically generates **two public API keys**:

**Where to find them:**
- Option 1: Go to **Project Settings → API Keys** → look for your Web app keys
- Option 2: Go to **Apps & providers** → click on your Web Billing app → view the API key section

You'll see:
1. **Production Key**: `rcb_xxxxxxxxxxxxx`
   - Use this for your production web app
   - Works with Paddle production environment
   - Safe to expose in client-side code

2. **Sandbox Key**: `rcb_sb_xxxxxxxxxxxxx`
   - Use this for development and testing
   - Works with Paddle sandbox/test environment
   - **Never use in production!**

**To verify your key is working:**
```bash
curl https://api.revenuecat.com/rcbilling/v1/branding \
  -H 'Authorization: Bearer rcb_your_key_here'
```
Should return a 200 response.

**Step 5: Paddle Product Configuration**
Create corresponding products in Paddle with the same pricing:
- starter_pack: $4.99
- popular_pack: $9.99
- professional_pack: $19.99
- enterprise_pack: $39.99

Make sure the product IDs in Paddle match the ones defined in `lib/models/credit_package.dart`.

### 4. Configure API Keys

You have several options for managing API keys in Flutter Web:

#### Option A: Environment Variables at Build Time (Recommended for Production)

Pass keys during build without storing in files:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=REVENUECAT_API_KEY_WEB=rcb_your_web_key
```

Then access in code:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const revenueCatKey = String.fromEnvironment('REVENUECAT_API_KEY_WEB');
```

#### Option B: .env File (Simpler for Development)

Create a `.env` file in the project root:

```env
# Supabase Configuration (anon key is safe for client-side)
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# RevenueCat Public API Key (safe for client-side)
# Web: rcb_xxxxxxxxxxxxx (production) or rcb_sb_xxxxxxxxxxxxx (sandbox)
REVENUECAT_API_KEY_WEB=rcb_your_web_key_here
```

**Security Notes**:
- ✅ The `SUPABASE_ANON_KEY` is a **public key** designed for client-side use (protected by RLS)
- ✅ The RevenueCat Web key (`rcb_` prefix) is a **public key** safe for client exposure
- ⚠️ Never use Supabase `service_role` key on the client side
- ⚠️ Never use RevenueCat secret API keys on the client side
- ✅ Add `.env` to `.gitignore` to avoid committing keys to version control

**What makes these keys safe?**
- These are publishable/public keys with limited permissions
- They can only perform client-side operations (auth, purchases, queries)
- Server admin operations require separate secret keys
- Similar security model to Stripe publishable keys or Firebase config

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

## Build Instructions

### Web
```bash
# Run on Web (development)
flutter run -d chrome

# Build for production
flutter build web --release

# Serve locally for testing
cd build/web
python3 -m http.server 8000
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

**Web + Paddle:**
- ✅ Verify Web API key format (`rcb_` prefix for production, `rcb_sb_` for sandbox)
- ✅ Check Paddle webhook configuration in Paddle dashboard
- ✅ Ensure Paddle products match RevenueCat configuration
- ✅ Test in sandbox mode first (`rcb_sb_` key)
- ✅ Check browser console for errors
- ✅ Verify Paddle seller account is fully verified
- ✅ Confirm products are active in Paddle dashboard

**General:**
- ✅ Verify RevenueCat Web API key in `.env`
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

# Rebuild web
flutter build web --release
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
  - [ ] Web: Test with Paddle sandbox mode
  - [ ] Credits are added after purchase
  - [ ] Credits sync to database for authenticated users
  - [ ] Purchase history appears in RevenueCat dashboard
  - [ ] Paddle checkout flow works correctly in browser

- [ ] **Cross-Browser Sync**
  - [ ] Sign in on Browser A (e.g., Chrome)
  - [ ] Purchase credits on Browser A
  - [ ] Sign in on Browser B (e.g., Firefox) with same account
  - [ ] Credits appear on Browser B
  - [ ] Test on different devices (desktop, mobile web)

## Notes

- ✅ Credits never expire
- ✅ Minimum purchase is 20 credits ($4.99)
- ✅ Guest users get 10 free credits (2 analyses) without signing in
- ✅ Authenticated users can purchase credits and sync across all browsers/devices
- ✅ RevenueCat free tier: $0-10k monthly tracked revenue
- ✅ Product IDs are centrally managed in `lib/models/credit_package.dart`
- ✅ Web-only deployment with Paddle as payment provider
- ✅ Supports all modern browsers (Chrome, Firefox, Safari, Edge)

## Support & Resources

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **RevenueCat Flutter Guide**: https://www.revenuecat.com/docs/getting-started/installation/flutter
- **RevenueCat + Paddle Integration**: https://www.revenuecat.com/docs/paddle
- **Paddle Docs**: https://developer.paddle.com/
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Web Support**: https://docs.flutter.dev/platform-integration/web
