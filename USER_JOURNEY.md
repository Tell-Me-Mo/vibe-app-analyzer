# User Journey - VibeCheck

## Overview
VibeCheck is a cross-platform application that helps developers analyze their AI-generated codebases for security vulnerabilities and business monitoring opportunities. The app uses a **credits-based system** where:
- **Each analysis costs 5 credits** (security or monitoring)
- **Each validation costs 1 credit** (validate fixes or implementations)
- Users get **10 free credits** on first launch
- Credits can be purchased through various payment methods

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

## Flow 6: Fix Validation Journey

### 6.1 After Analysis - Reviewing Results

**User completes security or monitoring analysis**

**Results Page shows:**
- Security issues OR monitoring recommendations
- Each finding has:
  - Title, description, severity/category
  - Claude Code prompt (with Copy button)
  - **"Validate Fix (1 credit)" button** (new!)
  - Validation status badge (if previously validated)

### 6.2 Fixing Issues in User's Environment

**User workflow:**
1. Reviews a security issue or monitoring recommendation
2. Clicks "Copy Prompt" to copy Claude Code prompt
3. Goes to their development environment (VSCode, terminal, etc.)
4. Uses Claude Code with the copied prompt to fix the issue
5. Reviews the changes, commits, and pushes to GitHub
6. Returns to VibeCheck to validate the fix

### 6.3 Initiating Validation

**User clicks "Validate Fix (1 credit)" button**

**Pre-validation checks:**

**Case 1: Sufficient Credits (≥1 credit)**
- Button changes to loading state: "Validating Fix..."
- 1 credit consumed immediately
- Validation begins

**Case 2: Insufficient Credits (<1 credit)**
- Dialog appears:
  - ⚠️ Icon + "Insufficient Credits" title
  - Message: "You need 1 credit to validate a fix. Would you like to purchase more credits?"
  - Buttons:
    - "Cancel" (secondary, grey)
    - "Buy Credits" (primary, blue)
- If "Buy Credits" clicked:
  - Navigate to `/credits` page
  - User can purchase credits
  - Return to results and retry validation

### 6.4 Validation in Progress

**What happens behind the scenes:**
1. Fetch latest code from GitHub repository
2. Send to OpenAI GPT-4o mini with validation prompt
3. AI analyzes if the fix is properly implemented
4. Returns validation result (passed/failed/error)

**User sees:**
- Circular progress spinner on button
- Button text: "Validating Fix..."
- Button disabled (can't click again)
- Duration: ~10-60 seconds depending on repository size

**Credits indicator updates:**
- Shows -1 credit during validation

### 6.5 Validation Complete - Success (Passed)

**Validation completes with status: PASSED ✅**

**UI updates:**
- Button text changes to "Re-validate Fix (1 credit)"
- **Green validation status badge appears** next to finding title:
  - ✅ "Fix Validated"
- **Validation result card appears** below the finding:
  - Green border and background
  - ✅ Icon + "Validation Passed" title
  - Timestamp: "Validated 2m ago"
  - Summary: Brief explanation of what was validated
  - Details: Specific checks performed and confirmed

**Snackbar notification:**
- "Fix Validated" with success icon
- Auto-dismisses after 3 seconds

**What this means:**
- User's fix is working correctly
- Security issue is resolved OR monitoring is implemented
- Can deploy to production with confidence

### 6.6 Validation Complete - Failed (Issues Remain)

**Validation completes with status: FAILED ❌**

**UI updates:**
- Button text: "Re-validate Fix (1 credit)"
- **Red validation status badge**:
  - ❌ "Fix Failed"
- **Validation result card** (red theme):
  - ❌ Icon + "Validation Failed" title
  - Timestamp
  - Summary: Why validation failed
  - Details: What was checked
  - **Red "Remaining Issues" section:**
    - List of issues still present
    - Bullet points with specific problems
  - **Blue "Recommendation" section:**
    - 💡 Icon + suggested next steps
    - What to do to pass validation

**Example Failed Validation:**
```
❌ Validation Failed
Validated 1m ago

Summary: SQL injection vulnerability still present

Details: While the prepared statement was added,
user input is still being concatenated in the WHERE clause.

Remaining Issues:
• Line 45: String concatenation in query builder
• Line 52: Unsanitized user input in ORDER BY clause

Recommendation: Use parameterized queries for all
dynamic values. Replace string concatenation with
placeholder binding.
```

**User actions:**
- Reviews remaining issues
- Makes additional fixes
- Clicks "Re-validate Fix (1 credit)" to try again

### 6.7 Validation Error

**Validation fails due to system error**

**UI updates:**
- **Orange validation status badge**:
  - ⚠️ "Validation Error"
- **Validation result card** (orange theme):
  - ⚠️ Icon + "Validation Error" title
  - Error details

**Behind the scenes:**
- **1 credit automatically refunded** ✅
- User can retry without losing credits

**Error snackbar:**
- "Validation failed: [error message]"
- Red background
- Auto-dismisses after 5 seconds

### 6.8 Re-validation After Additional Fixes

**User makes more changes and wants to validate again**

**Process:**
1. User updates code in their repository
2. Commits and pushes changes
3. Returns to VibeCheck results page
4. Clicks "Re-validate Fix (1 credit)"
5. Same validation flow runs
6. Previous validation result is replaced with new one

**Credit cost:**
- Each validation costs 1 credit (including re-validations)
- No limit on number of re-validations

### 6.9 Validation Persistence

**User closes app and returns later**

**What's preserved:**
- Validation status badge remains visible
- Validation result still displayed
- All data encrypted and stored locally
- For authenticated users: synced across devices

**Example:**
1. User validates fix on desktop → ✅ Passed
2. User opens app on mobile (same account)
3. Results page shows same ✅ "Fix Validated" badge
4. Full validation result visible on mobile

### 6.10 Validation for Monitoring Recommendations

**Same flow as security, different context:**

**Button text:**
- "Validate Implementation (1 credit)"
- While validating: "Validating Implementation..."

**Validation focuses on:**
- Whether monitoring code was added
- If it captures the right metrics/events
- Proper instrumentation
- Follows best practices

**Example Passed Validation:**
```
✅ Validation Passed
Validated 5m ago

Summary: User signup tracking properly implemented

Details: Analytics event is correctly fired on
successful registration. Event includes required
properties: user_id, signup_method, timestamp.

Implementation follows analytics best practices with
proper error handling and non-blocking execution.
```

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

### Insufficient Credits (Analysis)
- **Trigger:** User tries to analyze with < 5 credits
- **Response:** Dialog with "Buy Credits" option
- **Recovery:** Purchase credits or cancel

### Insufficient Credits (Validation)
- **Trigger:** User tries to validate with < 1 credit
- **Response:** Dialog: "You need 1 credit to validate a fix..."
- **Recovery:** Purchase credits or cancel validation

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

### Validation Fails After Credit Consumed
- **Trigger:** OpenAI API error, network timeout during validation
- **Response:** Error status badge, error snackbar
- **Recovery:** **1 credit refunded automatically**, user can retry

### Validation on Unchanged Code
- **Trigger:** User validates without making changes to repository
- **Response:** Validation runs normally (1 credit consumed)
- **Result:** Likely to fail with same issues as original analysis
- **Note:** No special detection, user can validate anytime

### Multiple Validations on Same Issue
- **Trigger:** User validates multiple times after incremental fixes
- **Response:** Each validation costs 1 credit
- **Result:** Previous validation result replaced with new one
- **Note:** Unlimited re-validations supported

---

## Key User Experience Principles

1. **Generous Free Tier:** 10 free credits = 2 analyses or mix of analysis + validations, no credit card required
2. **Transparent Pricing:** Clear credit costs (5 per analysis, 1 per validation), visible packages
3. **Seamless Authentication:** Optional but beneficial (sync across devices)
4. **Multiple Payment Options:** iOS/Android IAP, Stripe for web
5. **Credits Never Expire:** No pressure to use quickly
6. **Cross-Platform Sync:** Buy on one device, use on all
7. **Clear Visual Feedback:** Color-coded indicators (credits: green→yellow→red, validation: green/red/orange)
8. **Forgiving Errors:** Credits refunded if analysis or validation fails
9. **No Hidden Costs:** Upfront pricing, no subscriptions
10. **Privacy-Focused:** Guest mode for privacy-conscious users
11. **Validation Confidence:** AI-powered verification that fixes actually work
12. **Iterative Improvement:** Unlimited re-validations for continuous improvement

---

## Success Metrics (Analytics Goals)

### User Acquisition
- Guest user conversion rate (first launch → first analysis)
- Sign-up rate (guest → authenticated)
- Social auth vs email preference

### Engagement
- Average credits used per user
- Analysis completion rate
- **Validation usage rate (% of users who validate fixes)**
- **Average validations per analysis**
- Return user rate (7-day, 30-day)

### Validation Effectiveness
- **Validation success rate (passed vs failed)**
- **Average re-validations per issue**
- **Time between analysis and first validation**
- **Most validated issue types**

### Monetization
- Purchase conversion rate (insufficient credits → purchase)
- **Validation-driven purchases (bought credits specifically for validation)**
- Average revenue per user (ARPU)
- Most popular credit package
- Platform split (iOS vs Android vs Web purchases)

### Retention
- Credits remaining at churn
- Time to first purchase
- Second purchase rate
- **Validation feature retention boost**

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
