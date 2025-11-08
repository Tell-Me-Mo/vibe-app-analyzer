# User Journey - VibeCheck

## Overview
VibeCheck is a cross-platform application that helps developers analyze their AI-generated codebases for security vulnerabilities and business monitoring opportunities. The app uses a **credits-based system** where each analysis costs 5 credits. Users get **10 free credits** on first launch and can purchase more through various payment methods.

---

## User Types

### Guest User (Unauthenticated)
- Gets 10 free credits on first launch
- Can perform 2 analyses without signing in
- Credits stored locally
- Cannot purchase additional credits
- History stored locally (device-specific)

### Authenticated User
- Can sign in with Email, Google, or Apple
- Credits synced across all devices
- Can purchase credit packages
- Persistent history in cloud database
- Profile with account information

---

## Primary User Flows

## Flow 1: First-Time Guest User

### 1.1 Initial Launch (Welcome Experience)

**User opens app for the first time**

**What they see:**
1. **Welcome Popup appears automatically** (cannot be dismissed by clicking outside):
   - Large gift icon with gradient background
   - Title: "Welcome to VibeCheck!"
   - Highlighted badge showing:
     - Stars icon
     - "10 FREE Credits"
     - Subtitle: "2 free analyses"
   - Description: "Start analyzing your code for security vulnerabilities and monitoring opportunities right away!"
   - Note: "Each analysis costs 5 credits."
   - "Get Started" button (primary blue)

**User actions:**
- Clicks "Get Started"
- Popup closes
- 10 credits granted and saved locally

### 1.2 Landing Page (After Welcome)

**What they see:**
- **Top-right corner:**
  - **Credits Indicator** (color-coded badge):
    - Green (20+ credits)
    - Blue (10-19 credits)
    - Yellow (5-9 credits)
    - Red (0-4 credits)
    - Shows: "⭐ 10 credits" with "+" icon
    - Clickable to go to credits page
  - **Sign In button** (blue, with login icon)

- **Main content:**
  - Hero section:
    - Gradient icon
    - "VibeCheck" title
    - Tagline: "Check the vibe of your AI-generated code for security & monitoring gaps"
  - Input section:
    - URL input field: "https://github.com/username/repository"
    - Two action buttons:
      - "Analyze Security" (blue gradient)
      - "Analyze Monitoring" (green gradient)
  - History section (if any analyses exist):
    - "Recent Analyses" title
    - Demo examples + user analyses

**Responsive behavior:**
- Desktop (800px+): Constrained center layout
- Mobile: Full-width with padding, stacked buttons

### 1.3 First Analysis

**User enters GitHub URL and clicks "Analyze Security"**

**Pre-analysis validation:**
1. URL validation (must be valid GitHub repo URL)
2. **Credit check** (needs 5 credits)
   - ✅ Has 10 credits → Proceed
   - ❌ Insufficient → Show dialog (shouldn't happen on first use)

**Analysis screen:**
- Loading animation with progress (0-100%)
- Repository name displayed
- Analysis type badge
- Progress messages:
  - "Validating repository..." (10%)
  - "Cloning repository..." (30%)
  - "Running AI analysis..." (50%)
  - "Generating recommendations..." (90%)
  - "Analysis complete!" (100%)

**Behind the scenes:**
- 5 credits consumed **before** analysis starts
- Credits saved to local storage
- New balance: 10 - 5 = 5 credits

**Duration:** ~30-90 seconds

### 1.4 Results Dashboard

**Analysis completes successfully**

**What they see:**
- Credits indicator now shows: "⭐ 5 credits" (yellow, warning state)
- Results page with:
  - Repository info and timestamp
  - Analysis type badge
  - Summary section (total issues/recommendations)
  - Detailed findings cards
  - Each card has "Copy Prompt" button

**User actions:**
- Reviews results
- Copies prompts
- Returns to landing page

### 1.5 Second Analysis (Last Free One)

**User performs second analysis**

**Pre-analysis credit check:**
- Has 5 credits ✅
- Consumes 5 credits
- New balance: 0 credits

**Analysis completes:**
- Credits indicator now shows: "⭐ 0 credits" (red, critical state)

### 1.6 Third Analysis Attempt (No Credits)

**User tries third analysis without credits**

**Pre-analysis credit check:**
- Has 0 credits ❌
- **Dialog appears:**
  - Title: "Insufficient Credits"
  - Message: "You need 5 credits to run an analysis. Would you like to purchase more credits?"
  - Buttons:
    - "Cancel" (secondary)
    - "Buy Credits" (primary blue)

**User clicks "Buy Credits":**

**Navigation to Credits Page**

**What they see:**
- Header with back button and current credits indicator
- Title: "Get More Credits"
- Subtitle: "Choose the perfect package for your needs"
- **4 credit packages in responsive grid:**

| Package | Credits | Price | Savings | Special |
|---------|---------|-------|---------|---------|
| Starter Pack | 20 | $4.99 | - | - |
| Popular Pack | 50 | $9.99 | 20% | ⭐ POPULAR badge |
| Professional Pack | 120 | $19.99 | 35% | - |
| Enterprise Pack | 300 | $39.99 | 50% | - |

- Info section: "Each analysis costs 5 credits"
- Note: "Credits never expire and are synced across all your devices"

**Layout:**
- Desktop (800px+): 4 columns
- Tablet (600-800px): 2 columns
- Mobile (<600px): 1 column

**User clicks on any package:**

**Authentication Required Dialog appears:**
- Title: "Sign In Required"
- Message: "You need to sign in to purchase credits. Your purchases will be synced across devices."
- Buttons:
  - "Cancel"
  - "Sign In" (primary blue)

**User clicks "Sign In":**

---

## Flow 2: Authentication Journey

### 2.1 Sign In/Sign Up Page

**User navigates to /auth**

**What they see:**
- Back button (top-left)
- Title: "Welcome Back" (sign in) or "Create Account" (sign up)
- Subtitle: Context-appropriate message
- **Form fields:**
  - Name field (sign up only, optional)
  - Email field
  - Password field
- Primary button: "Sign In" or "Sign Up"
- Toggle link: "Don't have an account? Sign Up" / "Already have an account? Sign In"
- Divider with "OR"
- Social auth buttons:
  - "Continue with Google" (with G icon)
  - "Continue with Apple" (with Apple icon)

**Error states:**
- Inline validation
- Error banner at top (authentication failures)
- Network errors shown clearly

### 2.2 Email/Password Sign Up Flow

**User fills form and clicks "Sign Up"**

**What happens:**
1. Form validation (email format, password strength)
2. Supabase authentication
3. **User profile created in database:**
   ```json
   {
     "id": "user-uuid",
     "email": "user@example.com",
     "display_name": "John Doe",
     "credits": 10,
     "has_seen_welcome": false,
     "created_at": "2025-01-01T00:00:00Z"
   }
   ```
4. Local credits (0) **synced with profile** (10)
5. Navigate to landing page

**User now sees:**
- Credits indicator: "⭐ 10 credits" (back to blue/green)
- **Profile button** instead of "Sign In" (shows avatar or initials)

### 2.3 Google/Apple Sign In Flow

**User clicks "Continue with Google"**

**What happens:**
1. Google OAuth consent screen opens
2. User approves permissions
3. Returns to app with Google credentials
4. Supabase processes Google ID token
5. Profile created/fetched from database
6. Credits synced
7. Navigate to landing page

**Same flow for Apple Sign In**

---

## Flow 3: Authenticated User Experience

### 3.1 Authenticated Landing Page

**What they see (differences from guest):**
- **Top-right corner:**
  - Credits indicator (clickable)
  - **Profile chip** (instead of Sign In button):
    - Avatar (if available) or initials
    - Display name or email prefix
    - Clickable to go to /profile

**All other features same as guest**

### 3.2 Profile Page

**User clicks profile chip → Navigate to /profile**

**What they see:**
- Back button
- **Profile header:**
  - Large avatar (or initials in circle)
  - Display name
  - Email address
- **Credits section card:**
  - "Your Credits" title
  - Credits indicator
  - "Buy More Credits" button (primary blue, with cart icon)
- **Account Information card:**
  - Member since date
  - Account ID (first 8 chars of UUID)
- **Sign Out button** (outlined red)

**User actions:**
- View account info
- Click "Buy More Credits" → Navigate to /credits
- Sign out → Clears session, returns to landing as guest

### 3.3 Purchasing Credits (Authenticated)

**User clicks credits indicator or "Buy More Credits"**

**Navigate to Credits Page**

**What they see:**
- Same 4 packages as before
- No authentication required dialog (already signed in)

**User clicks "Purchase" on a package:**

**Payment flow begins:**
1. RevenueCat initializes with user ID
2. Fetches available packages from store
3. Native purchase dialog opens:
   - **iOS/Android:** Native in-app purchase (Apple/Google)
   - **Web:** Stripe checkout modal
4. User completes payment
5. **On success:**
   - Credits added to account
   - Database updated
   - Local storage synced
   - Success snackbar: "Successfully purchased 50 credits!"
   - Return to credits page

**On error:**
- User cancelled: Silent return
- Payment failed: Error dialog with support link
- Network error: Retry mechanism

### 3.4 Analysis with Credits

**User performs analysis while authenticated**

**Flow:**
1. Credit check (5 credits required)
2. **Credits consumed from local storage**
3. **Credits synced to database** (background)
4. Analysis proceeds
5. Results displayed
6. Credits indicator updates in real-time

**Benefits of authentication:**
- Credits persist across devices
- Analysis history in cloud
- Can purchase more credits anytime

---

## Flow 4: Returning User

### 4.1 Guest User Returns (Same Device)

**What happens:**
- Credits loaded from local storage
- Has seen welcome = true (no popup)
- Analysis history loaded from local storage
- Can continue using remaining credits

### 4.2 Authenticated User Returns (Any Device)

**What happens:**
- Auto-login via JWT token (if valid)
- Profile loaded from Supabase
- **Credits synced from database to local**
- Analysis history loaded from cloud
- Seamless experience across devices

**Session expired:**
- JWT token refresh attempted
- If refresh fails → Redirect to /auth
- User signs in again

---

## Flow 5: Advanced Scenarios

### 5.1 Guest → Authenticated Migration

**Scenario:** Guest user with local credits signs up

**What happens:**
1. User creates account
2. Profile created with default 10 credits
3. Local credits (e.g., 5 remaining) **NOT merged** (loses local credits)
4. User gets fresh 10 credits from new account
5. Local history **NOT migrated** to cloud

**Note:** This is a known limitation. Future improvement could merge credits.

### 5.2 Multiple Devices (Authenticated)

**Scenario:** User signs in on Phone, then on Web

**Phone:**
- Signs in → 50 credits
- Performs analysis → 45 credits remain
- Credits synced to database

**Web (5 minutes later):**
- Signs in → Loads profile
- Credits synced: Shows 45 credits ✅
- Performs analysis → 40 credits remain
- Synced to database

**Back to Phone:**
- App refreshes credits
- Shows 40 credits ✅

**Sync frequency:** Real-time with StreamProvider

### 5.3 Purchase on iOS, Use on Web

**iOS:**
- User purchases Professional Pack (120 credits)
- Apple In-App Purchase processes payment
- RevenueCat validates receipt
- Credits added to database: 40 + 120 = 160 credits

**Web (same user):**
- User navigates to app
- Credits synced from database
- Shows 160 credits ✅
- Can use credits purchased on iOS

**Cross-platform credits work seamlessly**

---

## Navigation Map

```
┌─────────────────────────────────────────────────────────┐
│                    Landing Page (/)                      │
│  ┌────────────────┐           ┌──────────────────┐     │
│  │ Credits Badge  │           │ Auth/Profile Btn │     │
│  └────────┬───────┘           └────────┬─────────┘     │
│           │                             │               │
│           ▼                             ▼               │
│    /credits (Buy)              /auth or /profile        │
└───────────┬─────────────────────────────┬───────────────┘
            │                             │
            │                             │
    ┌───────▼──────────┐        ┌────────▼────────┐
    │  Credits Page    │        │   Auth Page     │
    │  - 4 Packages    │        │  - Sign In/Up   │
    │  - Purchase      │        │  - Social Auth  │
    └───────┬──────────┘        └────────┬────────┘
            │                             │
            └──────────┬──────────────────┘
                       │
              ┌────────▼────────┐
              │  Profile Page   │
              │  - User Info    │
              │  - Credits      │
              │  - Sign Out     │
              └─────────────────┘

Analysis Flow (from Landing):
  Enter URL → Check Credits → Consume 5 → Analyze → Results
                    │
                    └─> Insufficient? → Dialog → Buy Credits or Cancel
```

---

## Edge Cases & Error Handling

### Insufficient Credits
- **Trigger:** User tries to analyze with < 5 credits
- **Response:** Dialog with "Buy Credits" option
- **Recovery:** Purchase credits or cancel

### Purchase Cancelled
- **Trigger:** User cancels payment dialog
- **Response:** Silent return to credits page
- **Recovery:** User can try again or go back

### Purchase Failed
- **Trigger:** Payment processor error
- **Response:** Error dialog with message and support link
- **Recovery:** Retry or contact support

### Authentication Failure
- **Trigger:** Invalid credentials, OAuth error
- **Response:** Error message on auth page
- **Recovery:** Retry with correct credentials

### Network Offline
- **Trigger:** No internet connection
- **Response:** Offline banner, disable analysis
- **Recovery:** Reconnect and retry

### Credits Out of Sync
- **Trigger:** Database update fails
- **Response:** Fallback to local storage
- **Recovery:** Background sync retry with exponential backoff

### Analysis Fails After Credits Consumed
- **Trigger:** OpenAI API error, network timeout
- **Response:** Error dialog shown
- **Recovery:** **Credits refunded** (5 added back automatically)

---

## Key User Experience Principles

1. **Generous Free Tier:** 10 free credits = 2 analyses, no credit card required
2. **Transparent Pricing:** Clear credit cost (5 per analysis), visible packages
3. **Seamless Authentication:** Optional but beneficial (sync across devices)
4. **Multiple Payment Options:** iOS/Android IAP, Stripe for web
5. **Credits Never Expire:** No pressure to use quickly
6. **Cross-Platform Sync:** Buy on one device, use on all
7. **Clear Visual Feedback:** Color-coded credit indicator (green→yellow→red)
8. **Forgiving Errors:** Credits refunded if analysis fails
9. **No Hidden Costs:** Upfront pricing, no subscriptions
10. **Privacy-Focused:** Guest mode for privacy-conscious users

---

## Success Metrics (Analytics Goals)

### User Acquisition
- Guest user conversion rate (first launch → first analysis)
- Sign-up rate (guest → authenticated)
- Social auth vs email preference

### Engagement
- Average credits used per user
- Analysis completion rate
- Return user rate (7-day, 30-day)

### Monetization
- Purchase conversion rate (insufficient credits → purchase)
- Average revenue per user (ARPU)
- Most popular credit package
- Platform split (iOS vs Android vs Web purchases)

### Retention
- Credits remaining at churn
- Time to first purchase
- Second purchase rate

---

## Future Enhancements

### Planned Features
1. **Subscription Option:** Unlimited analyses for $9.99/month
2. **Referral Program:** Invite friends, get bonus credits
3. **Team Accounts:** Share credits across organization
4. **Priority Queue:** Premium users get faster analysis
5. **Email Notifications:** Analysis complete, credits low
6. **Scheduled Analysis:** Auto-re-analyze repos on schedule
7. **Batch Analysis:** Analyze multiple repos at once
8. **Credit Bundles:** Bulk discounts for enterprises
9. **Social Sharing:** Share results on Twitter/LinkedIn
10. **Dark Mode:** User preference toggle

### Experimental Ideas
- **Freemium AI Model:** GPT-4o mini (free) vs GPT-4 (premium)
- **Credit Marketplace:** Transfer credits between users
- **Affiliate Program:** Earn credits by referring developers
- **GitHub Integration:** One-click from GitHub repo page
