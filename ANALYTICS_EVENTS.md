# Firebase Analytics Events - VibeCheck App

## Overview
This document lists all Firebase Analytics events tracked throughout the VibeCheck application.

## Event Tracking Coverage

### 1. **Screen Views** (Automatic)
**Location:** `lib/app.dart:17-20`
- Automatically tracks all screen navigation via FirebaseAnalyticsObserver
- Screens tracked:
  - `/` - Landing Page
  - `/analyze` - Analysis Loading Page
  - `/results/:id` - Results Page
  - `/auth` - Authentication Page
  - `/profile` - Profile Page
  - `/credits` - Credits Page

---

### 2. **App Lifecycle Events**

#### `app_open`
**Location:** `lib/main.dart:32`
- **When:** App launches
- **Parameters:** None
- **Purpose:** Track app opens and DAU (Daily Active Users)

---

### 3. **Landing Page Events**

#### `url_validation_failed`
**Location:** `lib/pages/landing_page.dart:66-72`
- **When:** User enters invalid URL
- **Parameters:**
  - `url` (string) - The invalid URL entered
  - `analysis_type` (string) - Type of analysis attempted
- **Purpose:** Track URL validation issues

#### `insufficient_credits`
**Location:** `lib/pages/landing_page.dart:80-86`
- **When:** User tries to analyze without enough credits
- **Parameters:**
  - `analysis_type` (string) - Type of analysis
  - `url_mode` (string) - URL mode (github/app)
- **Purpose:** Track credit-related friction in funnel

#### `analysis_initiated`
**Location:** `lib/pages/landing_page.dart:126-133`
- **When:** User clicks analyze button and has credits
- **Parameters:**
  - `analysis_type` (string) - security or monitoring
  - `url_mode` (string) - github or app URL
  - `is_github` (boolean) - Whether it's a GitHub URL
- **Purpose:** Track analysis feature usage

---

### 4. **Analysis Workflow Events**

#### `analysis_started` (via logAnalysisStarted)
**Location:** `lib/providers/analysis_provider.dart:143-145, 267-269`
- **When:** Analysis begins processing
- **Parameters:**
  - `code_type` (string) - 'github_repository' or 'runtime_app'
- **Purpose:** Track analysis attempts

#### `analysis_completed` (via logAnalysisCompleted)
**Location:** `lib/providers/analysis_provider.dart:222-226, 347-351`
- **When:** Analysis successfully completes
- **Parameters:**
  - `code_type` (string) - 'github_repository' or 'runtime_app'
  - `issues_found` (int) - Number of issues detected
  - `duration_ms` (int) - Time taken in milliseconds
- **Purpose:** Track analysis success and performance

#### `analysis_error`
**Location:** `lib/providers/analysis_provider.dart:234-240, 359-365`
- **When:** Analysis fails
- **Parameters:**
  - `error_type` (string) - 'static_code_analysis' or 'runtime_app_analysis'
  - `error_message` (string) - Error description
- **Purpose:** Track analysis failures for debugging

---

### 5. **Validation Events**

#### `validation_initiated`
**Location:** `lib/pages/results_page.dart:104-111, 145-152`
- **When:** User clicks validate button
- **Parameters:**
  - For security issues:
    - `validation_type` = 'security_issue'
    - `severity` (string) - Issue severity
    - `issue_title` (string) - Issue title
  - For monitoring:
    - `validation_type` = 'monitoring_recommendation'
    - `category` (string) - Recommendation category
    - `recommendation_title` (string) - Title
- **Purpose:** Track validation feature usage

#### `validation_insufficient_credits`
**Location:** `lib/pages/results_page.dart:130-135, 171-176`
- **When:** User tries to validate without credits
- **Parameters:**
  - `validation_type` (string) - Type of validation
- **Purpose:** Track credit friction in validation

#### `validation_completed`
**Location:** `lib/providers/validation_provider.dart:66-73, 147-154`
- **When:** Validation successfully completes
- **Parameters:**
  - `validation_type` (string) - Type of validation
  - `severity` or `category` (string) - Issue/recommendation details
  - `validation_result` (string) - Result status
- **Purpose:** Track validation success

#### `validation_error`
**Location:** `lib/providers/validation_provider.dart:85-91, 166-172`
- **When:** Validation fails
- **Parameters:**
  - `validation_type` (string) - Type of validation
  - `error_message` (string) - Error description
- **Purpose:** Track validation failures

---

### 6. **Payment Funnel Events**

#### `begin_checkout` (Firebase Standard Event)
**Location:** `lib/pages/credits_page.dart:53-56`
- **When:** User clicks purchase button (funnel entry)
- **Parameters:**
  - `value` (double) - Package price
  - `currency` (string) - Currency code (USD)
- **Purpose:** Track checkout initiation (Firebase standard ecommerce event)

#### `purchase_initiated`
**Location:** `lib/pages/credits_page.dart:59-66`
- **When:** User clicks purchase button
- **Parameters:**
  - `package_id` (string) - Credit package ID
  - `credits` (int) - Number of credits
  - `price` (double) - Package price
- **Purpose:** Track purchase funnel entry with custom parameters

#### `purchase_requires_auth`
**Location:** `lib/pages/credits_page.dart:67-71`
- **When:** Purchase requires authentication
- **Parameters:**
  - `package_id` (string) - Package being purchased
- **Purpose:** Track auth friction in purchase flow

#### `purchase` (Firebase Standard Event)
**Location:** `lib/pages/credits_page.dart:132-136`
- **When:** Purchase successfully completes
- **Parameters:**
  - `transaction_id` (string) - Unique transaction ID
  - `currency` (string) - Currency code (USD)
  - `value` (double) - Purchase amount
- **Purpose:** Track revenue (Firebase standard ecommerce event - appears in revenue reports)

#### `purchase_completed`
**Location:** `lib/pages/credits_page.dart:139-146`
- **When:** Purchase successfully completes
- **Parameters:**
  - `package_id` (string) - Package ID
  - `credits` (int) - Credits purchased
  - `price` (double) - Amount paid
- **Purpose:** Track detailed purchase metadata and conversions

#### `purchase_error`
**Location:** `lib/pages/credits_page.dart:150-157, 164-171`
- **When:** Purchase fails
- **Parameters:**
  - `package_id` (string) - Package ID
  - `error_type` (string) - 'payment_exception' or 'general'
  - `error_message` (string) - Error description
- **Purpose:** Track payment failures

---

### 7. **Authentication Events**

#### `login` (Firebase standard event)
**Location:** `lib/pages/auth_page.dart:89`
- **When:** User successfully signs in
- **Parameters:**
  - `method` = 'email_signin'
- **Purpose:** Track user logins

#### `sign_up` (Firebase standard event)
**Location:** `lib/pages/auth_page.dart:82`
- **When:** User successfully signs up
- **Parameters:**
  - `method` = 'email_signup'
- **Purpose:** Track new user acquisition

#### `auth_completed`
**Location:** `lib/pages/auth_page.dart:99-105`
- **When:** Authentication flow completes
- **Parameters:**
  - `auth_method` (string) - Method used
  - `auth_type` (string) - 'signup' or 'signin'
- **Purpose:** Track auth completion

#### `auth_error`
**Location:** `lib/pages/auth_page.dart:112-119, 126-133`
- **When:** Authentication fails
- **Parameters:**
  - `auth_method` (string) - Method attempted
  - `error_type` (string) - 'auth_exception' or 'general'
  - `error_message` (string) - Error description
- **Purpose:** Track auth failures

---

## Analytics Service Methods

### Standard Methods
- `logEvent()` - Custom events with parameters
- `logScreenView()` - Screen navigation
- `logAppOpen()` - App launches
- `logLogin()` - User sign in
- `logSignUp()` - User registration
- `logSearch()` - Search queries
- `logShare()` - Content sharing

### Custom Methods
- `logAnalysisStarted()` - Analysis begins
- `logAnalysisCompleted()` - Analysis finishes
- `setUserId()` - Identify user
- `setUserProperty()` - User attributes
- `setAnalyticsCollectionEnabled()` - Privacy control

---

## Key Metrics to Monitor

### User Engagement
- **DAU/MAU** - via `app_open` and `login` events
- **Screen Views** - via automatic tracking
- **Session Duration** - Firebase automatic

### Feature Adoption
- **Analysis Usage** - `analysis_initiated` → `analysis_completed`
- **Validation Usage** - `validation_initiated` → `validation_completed`
- **Analysis Type Preference** - security vs monitoring

### Conversion Funnels
1. **Purchase Funnel:**
   - `insufficient_credits` → `purchase_initiated` → `purchase_completed`

2. **Analysis Funnel:**
   - `analysis_initiated` → `analysis_started` → `analysis_completed`

3. **Validation Funnel:**
   - `validation_initiated` → `validation_completed`

### Revenue Metrics
- **Purchase Value** - via `purchase_completed` price parameter
- **Credits Sold** - via `purchase_completed` credits parameter
- **Package Popularity** - via `package_id` parameter

### Error Monitoring
- **Analysis Failures** - `analysis_error` events
- **Validation Failures** - `validation_error` events
- **Purchase Failures** - `purchase_error` events
- **Auth Failures** - `auth_error` events

### User Friction Points
- **URL Validation** - `url_validation_failed`
- **Insufficient Credits** - `insufficient_credits`, `validation_insufficient_credits`
- **Auth Required** - `purchase_requires_auth`

---

## Implementation Notes

1. **Privacy Compliant** - All analytics can be disabled via `setAnalyticsCollectionEnabled(false)`
2. **User ID Tracking** - Set after successful authentication
3. **Error Context** - All errors include descriptive messages
4. **Performance Data** - Analysis duration tracked in milliseconds
5. **Automatic Tracking** - Screen views handled by FirebaseAnalyticsObserver

---

## Next Steps for Analysis

1. Set up custom dashboards in Firebase Console
2. Create conversion funnels for key user journeys
3. Set up alerts for error rate spikes
4. Monitor revenue metrics via `purchase_completed` events
5. A/B test different credit packages using event parameters
