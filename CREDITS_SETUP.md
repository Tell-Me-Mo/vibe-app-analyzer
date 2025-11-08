# Credits & Authentication Setup Guide

This guide will help you set up the credits-based system with Supabase authentication and RevenueCat payments for VibeCheck.

## Overview

The app now includes:
- **Credits System**: 10 free credits on first launch, 5 credits per analysis
- **Authentication**: Sign in with Email, Google, or Apple (powered by Supabase)
- **Payments**: Purchase credit packages via RevenueCat (iOS/Android/Web)
- **User Profiles**: Synced across devices with credit balance

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
   - Register your App ID
   - Create a Services ID
   - Generate a key for Sign in with Apple
4. Add your Apple credentials to Supabase

### 4. Update .env File

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## RevenueCat Setup

### 1. Create a RevenueCat Account

1. Go to [https://www.revenuecat.com](https://www.revenuecat.com)
2. Create a new account and project
3. Note your API keys for each platform

### 2. Configure Products

Create the following products in RevenueCat:

| Product ID | Name | Credits | Price |
|------------|------|---------|-------|
| starter_pack | Starter Pack | 20 | $4.99 |
| popular_pack | Popular Pack | 50 | $9.99 |
| professional_pack | Professional Pack | 120 | $19.99 |
| enterprise_pack | Enterprise Pack | 300 | $39.99 |

### 3. Platform-Specific Setup

#### iOS/macOS
1. Connect your App Store Connect account
2. Create in-app purchases in App Store Connect
3. Link them in RevenueCat
4. Get your iOS API key

#### Android
1. Connect your Google Play Console
2. Create in-app products in Google Play Console
3. Link them in RevenueCat
4. Get your Android API key

#### Web (Stripe)
1. Connect your Stripe account to RevenueCat
2. Create products in RevenueCat's web configuration
3. Get your Web API key

### 4. Update .env File

```env
REVENUECAT_API_KEY_IOS=your-ios-key-here
REVENUECAT_API_KEY_ANDROID=your-android-key-here
REVENUECAT_API_KEY_WEB=your-web-key-here
```

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

## Troubleshooting

### Supabase Connection Issues
- Verify SUPABASE_URL and SUPABASE_ANON_KEY in .env
- Check that .env file is loaded in main.dart
- Ensure Supabase project is not paused

### Authentication Failures
- Check Supabase auth logs
- Verify OAuth credentials are correct
- Ensure redirect URLs are properly configured

### Payment Issues
- Verify RevenueCat API keys
- Check RevenueCat dashboard for transaction logs
- Ensure products are properly configured
- Test in sandbox mode first

## Notes

- Credits never expire
- Minimum purchase is 20 credits ($4.99)
- Guest users can use 10 free credits without signing in
- Authenticated users can purchase credits and sync across devices
- Free tier: $0-10k monthly revenue on RevenueCat
