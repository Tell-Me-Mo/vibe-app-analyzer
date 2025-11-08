# High-Level Design (HLD) - App Analyzer

## 1. System Overview

App Analyzer (VibeCheck) is a Flutter cross-platform application that analyzes both **GitHub repositories** (static code) and **live deployed applications** (runtime) for security vulnerabilities and business monitoring opportunities. The system uses OpenAI GPT-4o mini to perform intelligent analysis and generate actionable Claude Code prompts.

### 1.1 Key Features
- **Dual-mode analysis:**
  - **📝 Static Code:** Analyze GitHub repositories for code-level vulnerabilities and monitoring gaps
  - **🚀 Runtime:** Analyze live deployed applications for production security headers, cookies, monitoring tools, and performance
- **Automatic URL detection:** Intelligently routes to static or runtime analysis based on URL type
- **Credits-based system:** 10 free credits on first launch, 5 credits per analysis, 1 credit per validation
- **Authentication:** Sign in with Email, Google, or Apple (Supabase)
- **Payment integration:** Purchase credit packages via RevenueCat (iOS/Android/Web)
- **User profiles:** Synced across devices with credit balance
- **Two analysis types:** Security & Monitoring (available for both static and runtime modes)
- **Synchronous analysis** with real-time progress indication
- **Claude Code-compatible** prompt generation
- **Fix validation:** AI-powered validation of security fixes and monitoring implementations (1 credit each, static code only)
- **Guest mode:** Use app without authentication (local storage)
- **Responsive UI:** Desktop, tablet, and mobile support
- **Analysis history** with demo examples, validation results, and mode badges
- **Cross-platform:** Web, iOS, Android, macOS, Linux, Windows

---

## 2. Architecture Diagram (Flutter Multi-Platform + Cloud Services)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Flutter Client (All Platforms)                    │
│  ┌──────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐   │
│  │ Landing  │ │ Analysis│ │ Results │ │  Auth   │ │ Profile/ │   │
│  │   Page   │─>│ Loading │─>│Dashboard│ │  Page   │ │ Credits  │   │
│  └──────────┘ └─────────┘ └─────────┘ └─────────┘ └──────────┘   │
│       │              │           │           │            │         │
│       └──────────────┴───────────┴───────────┴────────────┘         │
│                                  │                                  │
│                         ┌────────▼────────┐                         │
│                         │   State Mgmt    │                         │
│                         │   (Riverpod)    │                         │
│                         └────────┬────────┘                         │
│                                  │                                  │
│     ┌────────────────────────────┼───────────────────────────────┐ │
│     │            │               │               │       │       │ │
│ ┌───▼────┐ ┌────▼────┐ ┌────────▼───────┐ ┌────▼────┐ ┌──▼───┐ │ │
│ │ GitHub │ │ OpenAI  │ │ Auth Service   │ │ Credits │ │Valida│ │ │
│ │Service │ │ Service │ │   (Supabase)   │ │ Service │ │-tion │ │ │
│ └───┬────┘ └────┬────┘ └────────┬───────┘ └────┬────┘ └──┬───┘ │ │
│     │           │               │               │         │     │ │
│     │           │               │               │          │      │
│     │           │          ┌────▼────┐          │          │      │
│     │           │          │ Storage │          │          │      │
│     │           │          │ Service │          │          │      │
│     │           │          │(Encrypted)        │          │      │
│     │           │          └─────────┘          │          │      │
└─────┼───────────┼───────────────┼───────────────┼──────────┼──────┘
      │           │               │               │          │
      │ HTTPS     │ HTTPS         │ HTTPS         │ Local    │ HTTPS
      │           │               │               │ Storage  │
┌─────▼─────┐ ┌───▼──────┐ ┌──────▼──────┐ ┌─────▼─────┐ ┌─▼────────┐
│  GitHub   │ │  OpenAI  │ │  Supabase   │ │ Hive/     │ │RevenueCat│
│    API    │ │GPT-4o min│ │ (Auth+DB)   │ │SharedPrefs│ │(Payments)│
└───────────┘ └──────────┘ └─────────────┘ └───────────┘ └──────────┘
                                   │
                           ┌───────▼────────┐
                           │   PostgreSQL   │
                           │  (User Profiles│
                           │   & Credits)   │
                           └────────────────┘
```

**Note:** All logic runs in Flutter client. Cloud services handle auth, database, and payments.

---

## 3. Technology Stack

### 3.1 Frontend (Flutter)
- **Framework:** Flutter 3.9.2+ (Web, iOS, Android, Desktop)
- **State Management:** Riverpod 2.6.1+
- **HTTP Client:** dio 5.7.0 (for API calls)
- **Local Storage:**
  - shared_preferences 2.3.3 (credits, session)
  - hive 2.2.3 + hive_flutter 1.1.0 (analysis history)
  - flutter_secure_storage 9.2.2 (encryption keys)
  - encrypt 5.0.3 (data encryption)
- **UI Components:** Material 3 design system
- **Animations:** Built-in Flutter animations
- **Routing:** go_router 14.6.2
- **Responsive:** Custom ConstrainedBox + LayoutBuilder patterns

### 3.2 Authentication & Payments
- **Auth Provider:** Supabase Flutter 2.9.3
  - Email/password authentication
  - Google Sign In 6.2.2
  - Apple Sign In 6.1.3
- **Payment Provider:** RevenueCat (purchases_flutter 8.4.1)
  - iOS/Android in-app purchases
  - Web payments via Stripe integration
- **Database:** Supabase PostgreSQL (user profiles, credits)

### 3.3 External Services
- **GitHub API:** Repository content retrieval
- **OpenAI API:** GPT-4o mini for code analysis
- **Supabase:** Authentication and user data
- **RevenueCat:** Payment processing and subscription management
- **Hosting:**
  - Web: Firebase Hosting / Vercel / Netlify
  - Mobile: App Store / Google Play
  - Desktop: Direct distribution

**Important:** OpenAI API key must be handled carefully in client-side apps. For MVP, it will be embedded, but should be moved to a proxy/backend in production.

---

## 4. Component Design

### 4.1 Frontend Components

#### 4.1.1 Pages/Screens
```
lib/
├── main.dart                    # App entry point (with service initialization)
├── app.dart                     # Root app widget with routing
├── pages/
│   ├── landing_page.dart        # Main landing screen (with credits/auth UI)
│   ├── analysis_loading_page.dart # Analysis in progress
│   ├── results_page.dart        # Results dashboard
│   ├── auth_page.dart           # Sign in/sign up page
│   ├── profile_page.dart        # User profile with credits
│   └── credits_page.dart        # Credit packages purchase page
```

#### 4.1.2 Widgets
```
lib/widgets/
├── common/
│   ├── app_button.dart          # Custom button component
│   ├── app_text_field.dart      # Custom text input
│   ├── loading_animation.dart   # Analysis loading animation
│   ├── severity_badge.dart      # Color-coded badges
│   ├── category_badge.dart      # Category badges
│   ├── validation_status_badge.dart # Validation status indicators
│   ├── validation_result_display.dart # Validation result card
│   ├── welcome_popup.dart       # First-launch free credits popup
│   ├── credits_indicator.dart   # Credit balance indicator
│   └── auth_button.dart         # Login/profile button
├── landing/
│   └── history_card.dart        # Analysis history card
├── results/
│   ├── issue_card.dart          # Security issue display (with validation button)
│   └── recommendation_card.dart # Monitoring recommendation (with validation button)
```

#### 4.1.3 State Management (Riverpod)
```
lib/providers/
├── analysis_provider.dart       # Current analysis state (with credit consumption)
├── history_provider.dart        # Analysis history (with update support)
└── validation_provider.dart     # Validation state management

# Note: Auth and credits state managed via services with StreamProviders
```

#### 4.1.4 Services
```
lib/services/
├── github_service.dart          # GitHub API integration (static code analysis)
├── app_runtime_service.dart     # Live app fetching and analysis (NEW!)
├── openai_service.dart          # OpenAI GPT-4o mini integration (analysis + validation)
│                                # - Static code prompts
│                                # - Runtime analysis prompts
├── storage_service.dart         # Encrypted local storage (Hive) with update support
├── auth_service.dart            # Supabase authentication
├── credits_service.dart         # Credits management (with refund support)
├── payment_service.dart         # RevenueCat payment integration
└── validation_service.dart      # Fix/implementation validation (1 credit each)
```

#### 4.1.5 Models
```
lib/models/
├── analysis_type.dart           # Enum for analysis types (Security, Monitoring)
├── analysis_mode.dart           # Enum for analysis modes (Static Code, Runtime) - NEW!
├── analysis_result.dart         # Response data (with JSON serialization + analysisMode)
├── runtime_analysis_data.dart   # Runtime app data model - NEW!
│   ├── DetectedTools            # 17+ monitoring tools detection
│   ├── PerformanceMetrics       # Page load, TTFB, ratings
│   └── SecurityConfig           # HTTPS, headers, cookies, security score
├── security_issue.dart          # Security finding model (with validation fields)
├── monitoring_recommendation.dart # Monitoring suggestion (with validation fields)
├── severity.dart                # Severity enum
├── validation_status.dart       # Enum for validation states
├── validation_result.dart       # Validation response data
├── user_profile.dart            # User profile with credits
└── credit_package.dart          # Credit package definitions
```

### 4.2 Backend Components

#### 4.2.1 API Endpoints
```
/api/v1/
├── POST /analyze              # Main analysis endpoint
│   Body: {
│     "repository_url": "string",
│     "analysis_type": "security" | "monitoring",
│     "session_id": "uuid"
│   }
│   Response: AnalysisResult
│
├── GET /history/:session_id   # Get user's analysis history
│   Response: List<AnalysisHistoryItem>
│
├── GET /result/:analysis_id   # Get specific analysis result
│   Response: AnalysisResult
│
└── GET /demo-examples         # Get pre-populated demo results
    Response: List<AnalysisResult>
```

#### 4.2.2 Backend Structure
```
backend/
├── bin/
│   └── server.dart              # Server entry point
├── lib/
│   ├── handlers/
│   │   ├── analyze_handler.dart # Analysis endpoint logic
│   │   ├── history_handler.dart # History retrieval
│   │   └── demo_handler.dart    # Demo examples
│   ├── services/
│   │   ├── github_service.dart  # GitHub API integration
│   │   ├── openai_service.dart  # OpenAI GPT-4o mini
│   │   └── db_service.dart      # SQLite operations
│   ├── models/
│   │   ├── analysis_models.dart # Data models
│   │   └── db_models.dart       # Database schemas
│   └── utils/
│       ├── validation.dart      # URL/input validation
│       └── prompt_builder.dart  # AI prompt construction
├── database/
│   └── schema.sql               # Database schema
└── docker/
    └── Dockerfile               # Container config
```

---

## 5. Data Models

### 5.1 Analysis Request
```dart
class AnalysisRequest {
  final String repositoryUrl;
  final AnalysisType analysisType; // security | monitoring
  final String sessionId;
  final DateTime timestamp;
}
```

### 5.2 Analysis Result
```dart
class AnalysisResult {
  final String id;
  final String repositoryUrl;
  final String repositoryName;
  final AnalysisType analysisType;
  final DateTime timestamp;
  final AnalysisSummary summary;
  final List<Finding> findings; // SecurityIssue or MonitoringRec
  final String status; // completed | failed
  final String? error;
}
```

### 5.3 Security Issue
```dart
class SecurityIssue implements Finding {
  final String id;
  final String title;
  final String category;
  final Severity severity; // critical | high | medium | low
  final String description;
  final String aiGenerationRisk;
  final String claudeCodePrompt;
  final String? filePath;
  final int? lineNumber;
  final ValidationStatus validationStatus; // notStarted | validating | passed | failed | error
  final ValidationResult? validationResult;
}
```

### 5.4 Monitoring Recommendation
```dart
class MonitoringRecommendation implements Finding {
  final String id;
  final String title;
  final String category; // analytics | error_tracking | business_metrics
  final String description;
  final String businessValue;
  final String claudeCodePrompt;
  final String? filePath;
  final int? lineNumber;
  final ValidationStatus validationStatus; // notStarted | validating | passed | failed | error
  final ValidationResult? validationResult;
}
```

### 5.5 Validation Status
```dart
enum ValidationStatus {
  notStarted,  // Default state, not yet validated
  validating,  // Currently validating fix/implementation
  passed,      // Validation successful, fix works
  failed,      // Validation failed, issues remain
  error,       // Validation error occurred
}
```

### 5.6 Validation Result
```dart
class ValidationResult {
  final String id;
  final ValidationStatus status;
  final DateTime timestamp;
  final String? summary;           // Brief validation summary
  final String? details;           // Detailed explanation
  final List<String>? remainingIssues;  // Issues found if failed
  final String? recommendation;    // Next steps if failed
}
```

### 5.7 Database Schema
```sql
-- analyses table
CREATE TABLE analyses (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  repository_url TEXT NOT NULL,
  repository_name TEXT NOT NULL,
  analysis_type TEXT NOT NULL, -- 'security' | 'monitoring'
  status TEXT NOT NULL,         -- 'completed' | 'failed'
  timestamp INTEGER NOT NULL,
  result_json TEXT NOT NULL,    -- Serialized AnalysisResult
  error TEXT,
  INDEX idx_session (session_id),
  INDEX idx_timestamp (timestamp DESC)
);

-- demo_examples table (pre-populated)
CREATE TABLE demo_examples (
  id TEXT PRIMARY KEY,
  analysis_type TEXT NOT NULL,
  repository_name TEXT NOT NULL,
  result_json TEXT NOT NULL
);
```

---

## 6. Analysis Flow (Detailed)

### 6.1 URL Detection & Routing
```
User Input URL
    │
    ▼
Validators.detectUrlType()
    │
    ├─> GitHub URL (github.com/owner/repo)
    │   └─> AnalysisMode.staticCode
    │
    └─> App URL (https://yourapp.com)
        └─> AnalysisMode.runtime
```

### 6.2 Static Code - Security Analysis Pipeline
```
1. Repository Retrieval
   └─> GitHub API: Fetch file tree & code files

2. Code Aggregation
   └─> Combine relevant files (max tokens ~50k)

3. AI Analysis (OpenAI GPT-4o mini)
   Input Prompt:
   """
   You are a security expert analyzing AI-generated code.
   Focus on vulnerabilities common in code from AI assistants:
   - Hardcoded secrets/credentials
   - Missing input validation
   - Insecure authentication patterns
   - SQL injection risks
   - XSS vulnerabilities
   - Insecure API endpoints
   - Missing CORS/security headers

   Analyze this repository: [code]

   Return JSON:
   {
     "summary": { "total": int, "bySeverity": {...} },
     "issues": [
       {
         "title": "...",
         "category": "...",
         "severity": "critical|high|medium|low",
         "description": "...",
         "aiGenerationRisk": "Why AI might create this",
         "claudeCodePrompt": "Prompt to fix this issue"
       }
     ]
   }
   """

4. Result Parsing & Validation
   └─> Parse JSON, validate structure

5. Storage & Return
   └─> Save to SQLite, return to frontend
```

### 6.3 Static Code - Monitoring Analysis Pipeline
```
1. Repository Retrieval
   └─> Same as security analysis

2. Code Aggregation
   └─> Focus on business logic files

3. AI Analysis (OpenAI GPT-4o mini)
   Input Prompt:
   """
   You are an observability expert analyzing business applications.
   Identify missing business monitoring opportunities:
   - User action tracking (signups, purchases, clicks)
   - Conversion funnel metrics
   - Business KPI tracking
   - Custom event logging
   - User behavior analytics
   - Performance monitoring (API latency, load times)

   Analyze this repository: [code]

   Return JSON:
   {
     "summary": { "total": int, "byCategory": {...} },
     "recommendations": [
       {
         "title": "...",
         "category": "analytics|error_tracking|business_metrics",
         "description": "...",
         "businessValue": "Why this matters",
         "claudeCodePrompt": "Prompt to implement this"
       }
     ]
   }
   """

4. Result Parsing & Validation
   └─> Parse JSON, validate structure

5. Storage & Return
   └─> Save to SQLite, return to frontend
```

### 6.4 Runtime - Security Analysis Pipeline
```
1. App URL Validation
   └─> Validate URL format and accessibility

2. Live App Fetching (AppRuntimeService)
   └─> HTTP GET request with proper headers
   └─> Measure TTFB and page load time
   └─> Extract HTML content

3. Runtime Data Collection
   ├─> HTTP Security Headers Analysis
   │   ├─> HTTPS, HSTS, CSP, X-Frame-Options
   │   ├─> X-Content-Type-Options, Referrer-Policy
   │   └─> Permissions-Policy, CORS
   │
   ├─> Cookie Security Analysis
   │   ├─> Secure flag
   │   ├─> HttpOnly flag
   │   └─> SameSite attribute
   │
   ├─> Performance Metrics
   │   ├─> Page load time
   │   └─> Time to First Byte (TTFB)
   │
   └─> Monitoring Tools Detection (17+ tools)
       ├─> Analytics: GA, Mixpanel, Segment, etc.
       ├─> Error Tracking: Sentry, Bugsnag, etc.
       ├─> APM: New Relic, Datadog, etc.
       └─> Session Replay: Hotjar, FullStory, etc.

4. AI Analysis (OpenAI GPT-4o mini)
   Input Prompt:
   """
   You are a security expert analyzing DEPLOYED applications.

   Focus on RUNTIME security issues:
   - Missing or misconfigured security headers
   - Insecure cookie configurations
   - CORS misconfigurations
   - Exposed sensitive data in HTML/JS
   - Missing HTTPS or weak TLS

   Detected Configuration:
   - Security Score: X/10
   - Headers: [detected headers]
   - Cookies: [cookie analysis]
   - Performance: [metrics]

   Return JSON:
   {
     "summary": { "total": int, "bySeverity": {...} },
     "issues": [
       {
         "title": "...",
         "severity": "critical|high|medium|low",
         "description": "Runtime security issue",
         "runtimeRisk": "Why this matters in production",
         "claudeCodePrompt": "How to fix in deployment",
         "filePath": null,
         "lineNumber": null
       }
     ]
   }
   """

5. Result Parsing & Validation
   └─> Parse JSON, validate structure

6. Storage & Return
   └─> Save to local storage with analysisMode: runtime
```

### 6.5 Runtime - Monitoring Analysis Pipeline
```
1. App URL Validation
   └─> Same as runtime security

2. Live App Fetching
   └─> Same as runtime security

3. Runtime Data Collection
   ├─> Monitoring Tools Detection
   │   ├─> Google Analytics, Mixpanel, Amplitude, etc.
   │   ├─> Sentry, Bugsnag, Rollbar, etc.
   │   ├─> New Relic, Datadog, AppDynamics
   │   └─> Meta Pixel, LinkedIn Tag
   │
   └─> Performance Metrics
       ├─> Page load time analysis
       └─> Performance rating

4. AI Analysis (OpenAI GPT-4o mini)
   Input Prompt:
   """
   You are an observability expert analyzing DEPLOYED apps.

   Focus on what monitoring is MISSING or INCOMPLETE:
   - No analytics (or missing conversion tracking)
   - No error tracking (or incomplete setup)
   - Missing performance monitoring
   - Business metrics gaps

   Detected Tools:
   ✓ Google Analytics detected
   ✗ No error tracking
   ✗ No session replay

   Return JSON:
   {
     "summary": { "total": int, "byCategory": {...} },
     "recommendations": [
       {
         "title": "...",
         "category": "analytics|error_tracking|business_metrics",
         "description": "What's missing",
         "businessValue": "Impact on business",
         "claudeCodePrompt": "How to implement",
         "filePath": null,
         "lineNumber": null
       }
     ]
   }
   """

5. Result Parsing & Validation
   └─> Parse JSON, validate structure

6. Storage & Return
   └─> Save to local storage with analysisMode: runtime
```

### 6.6 Fix Validation Pipeline (Static Code Only)
```
1. Credit Check
   └─> Verify user has ≥1 credit for validation

2. Credit Consumption
   └─> Consume 1 credit before validation starts

3. Update Status
   └─> Set finding validationStatus to "validating"

4. Repository Code Fetch
   └─> Fetch updated code from GitHub repository
   └─> Same logic as analysis (filter relevant files, max 100KB)

5. AI Validation (OpenAI GPT-4o mini)
   For Security Issues:
   Input Prompt:
   """
   You are a security expert validating a fix.

   Original Issue:
   - Title: {issue.title}
   - Severity: {issue.severity}
   - Description: {issue.description}
   - File: {issue.filePath}:{issue.lineNumber}

   Updated Code: [fetched code]

   Validation Checklist:
   1. Vulnerable code pattern removed/fixed
   2. Fix addresses root cause
   3. No new security issues introduced
   4. Follows security best practices

   Return JSON:
   {
     "status": "passed" | "failed",
     "summary": "Brief summary",
     "details": "Detailed explanation",
     "remainingIssues": ["..."] (if failed),
     "recommendation": "..." (if failed)
   }
   """

   For Monitoring Recommendations:
   Input Prompt:
   """
   You are an observability expert validating implementation.

   Original Recommendation:
   - Title: {rec.title}
   - Category: {rec.category}
   - Business Value: {rec.businessValue}
   - File: {rec.filePath}:{rec.lineNumber}

   Updated Code: [fetched code]

   Validation Checklist:
   1. Monitoring/tracking code added
   2. Captures recommended metrics/events
   3. Proper instrumentation
   4. Follows best practices

   Return JSON: (same format as security)
   """

6. Result Parsing
   └─> Parse JSON, create ValidationResult

7. Update Finding
   └─> Update SecurityIssue/MonitoringRecommendation with validation result
   └─> Set validationStatus to "passed", "failed", or "error"

8. Persist Update
   └─> Update AnalysisResult in storage
   └─> Encrypted storage preserves validation history

9. UI Update
   └─> ValidationProvider triggers state update
   └─> Results page rebuilds with validation badge and result

Error Handling:
   └─> On any error: Refund 1 credit
   └─> Set validationStatus to "error"
   └─> Show error message to user
```

---

## 7. Key Algorithms & Logic

### 7.1 Repository Validation
```dart
bool isValidGitHubUrl(String url) {
  final regex = RegExp(
    r'^https?:\/\/(www\.)?github\.com\/[\w-]+\/[\w.-]+\/?$'
  );
  return regex.hasMatch(url);
}
```

### 7.2 Token Management (OpenAI)
```dart
// Estimate tokens and truncate code if needed
String prepareCodeForAnalysis(List<File> files) {
  const maxTokens = 50000; // Conservative limit
  String aggregated = '';
  int estimatedTokens = 0;

  for (var file in files) {
    int fileTokens = (file.content.length / 4).round();
    if (estimatedTokens + fileTokens > maxTokens) break;
    aggregated += '--- ${file.path} ---\n${file.content}\n\n';
    estimatedTokens += fileTokens;
  }

  return aggregated;
}
```

### 7.3 Session Management
```dart
Future<String> getOrCreateSessionId() async {
  final prefs = await SharedPreferences.getInstance();
  String? sessionId = prefs.getString('session_id');

  if (sessionId == null) {
    sessionId = Uuid().v4();
    await prefs.setString('session_id', sessionId);
  }

  return sessionId;
}
```

---

## 8. Security Considerations

### 8.1 Input Validation
- Validate GitHub URLs (whitelist domain)
- Prevent SSRF attacks (restrict to GitHub API only)
- Rate limiting per session (max 10 requests/hour)

### 8.2 API Key Management
- Store OpenAI API key in environment variables
- Never expose keys to frontend
- Rotate keys regularly

### 8.3 Data Privacy
- No personal data collected (anonymous sessions)
- Results stored for 30 days, then purged
- No GitHub authentication = no access to private data

### 8.4 Code Injection Prevention
- No execution of analyzed code
- Sanitize all outputs before display
- Use parameterized queries for SQLite

---

## 9. Performance Optimization

### 9.1 Frontend
- Lazy loading for history section
- Debounce URL input validation
- Code splitting (separate bundle for results page)
- Image optimization for demo examples

### 9.2 Backend
- Cache GitHub API responses (5 min TTL)
- Connection pooling for SQLite
- Async/await for all I/O operations
- Timeout handlers (60s max per analysis)

### 9.3 OpenAI API
- Use GPT-4o mini (cost-effective)
- Stream responses (if possible) for perceived speed
- Retry logic with exponential backoff

---

## 10. Error Handling

### 10.1 Frontend Error States
| Error Type | User Message | Recovery Action |
|------------|--------------|-----------------|
| Invalid URL | "Please enter a valid GitHub URL" | Clear error on input change |
| Network timeout | "Connection lost. Please try again." | Retry button |
| Server error | "Analysis failed. Try again later." | Back to landing page |
| Empty results | "No issues found!" | Show success message |

### 10.2 Backend Error Handling
- Try/catch on all external API calls
- Log errors to console (structured logging)
- Return standardized error responses:
  ```json
  {
    "error": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Try again in 1 hour.",
    "retryAfter": 3600
  }
  ```

---

## 11. Deployment Architecture

### 11.1 Frontend Deployment
```
Flutter Web Build
    ├─> flutter build web --release
    └─> Deploy to Firebase Hosting / Vercel
        └─> CDN distribution (global edge caching)
```

### 11.2 Backend Deployment
```
Dart Server (Docker Container)
    ├─> Dockerfile with Dart SDK
    ├─> Environment variables (.env file)
    │   ├─> OPENAI_API_KEY
    │   ├─> GITHUB_TOKEN (optional, for rate limits)
    │   └─> DATABASE_PATH
    └─> Deploy to Cloud Run / Railway / Heroku
        └─> Auto-scaling (0-5 instances)
```

### 11.3 Database
- SQLite file on persistent volume
- Backup strategy: Daily exports to cloud storage

---

## 12. Configuration & Environment Variables

### 12.1 Frontend (.env)
```
FLUTTER_APP_API_BASE_URL=https://api.appanalyzer.com
FLUTTER_APP_ENV=production
```

### 12.2 Backend (.env)
```
OPENAI_API_KEY=sk-...
GITHUB_TOKEN=ghp_... (optional)
PORT=8080
DATABASE_PATH=/data/app_analyzer.db
CORS_ORIGINS=https://appanalyzer.com
RATE_LIMIT_PER_SESSION=10
RATE_LIMIT_WINDOW_HOURS=1
```

---

## 13. Testing Strategy

### 13.1 Frontend Tests
- Widget tests for each component
- Integration tests for full user flows
- Responsive layout tests (desktop/mobile)

### 13.2 Backend Tests
- Unit tests for services (mocked dependencies)
- Integration tests for API endpoints
- Load testing (100 concurrent analyses)

### 13.3 End-to-End Tests
- Selenium/Playwright for critical paths
- Test with real GitHub repos (public test repos)

---

## 14. Monitoring & Observability (Post-MVP)

- Application performance monitoring (APM)
- Error tracking (Sentry)
- Analytics (Google Analytics/Plausible)
- OpenAI API usage tracking
- Database query performance

---

## 15. Future Enhancements (Out of Scope for MVP)

- User authentication (save history across devices)
- Private repository support (GitHub OAuth)
- Scheduled re-analysis (monitor repos over time)
- Export reports as PDF
- API for programmatic access
- Slack/Discord integration for notifications
- Multi-language support
- Custom analysis rules/configurations

---

## 16. Development Phases

### Phase 1: Core Backend (Week 1)
- Set up Dart server with shelf
- Implement GitHub API integration
- Implement OpenAI API integration
- Build analysis pipeline
- Create SQLite schema & CRUD operations

### Phase 2: Core Frontend (Week 2)
- Set up Flutter Web project structure
- Build landing page UI
- Build analysis loading page
- Build results dashboard
- Implement state management with Riverpod

### Phase 3: Integration & Polish (Week 3)
- Connect frontend to backend
- Implement session management
- Add demo examples
- Responsive design testing
- Error handling & validation

### Phase 4: Testing & Deployment (Week 4)
- Write tests
- Performance optimization
- Deploy backend (Cloud Run)
- Deploy frontend (Firebase Hosting)
- End-to-end testing in production

---

## 17. Success Criteria

- [ ] User can analyze a public GitHub repo in <60 seconds
- [ ] Results display with actionable Claude Code prompts
- [ ] History persists across sessions (cookie-based)
- [ ] Works on desktop and mobile browsers
- [ ] 95%+ uptime
- [ ] Handles 100+ daily analyses without issues
