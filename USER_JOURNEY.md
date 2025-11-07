# User Journey - App Analyzer

## Overview
App Analyzer is a web application that helps developers analyze their AI-generated codebases for security vulnerabilities and business monitoring opportunities. Users can analyze public GitHub repositories without authentication.

---

## Primary User Flow

### 1. Landing Page (Initial Visit)

**User arrives at the app**

**What they see:**
- Clean, modern header with app logo/title: "App Analyzer"
- Brief tagline: "Analyze your AI-generated apps for security & monitoring insights"
- Main input section:
  - Text input field with placeholder: "Enter GitHub repository URL (e.g., https://github.com/username/repo)"
  - Two prominent CTA buttons side-by-side:
    - "Analyze Security" (primary color)
    - "Analyze Monitoring" (secondary color)
- History section below (collapsible/scrollable):
  - Title: "Recent Analyses"
  - 2 demo example cards (pre-populated):
    - Example 1: "Demo Security Analysis - React E-commerce App"
    - Example 2: "Demo Monitoring Analysis - Flutter Todo App"
  - User's previous analyses (if any, identified by cookie)
  - Each card shows:
    - Repository name
    - Analysis type badge (Security/Monitoring)
    - Timestamp
    - "View Results" clickable area

**User actions:**
- Can paste GitHub repo URL
- Can click either "Analyze Security" or "Analyze Monitoring"
- Can click on history cards to view previous results

**Responsive behavior:**
- Desktop: Input and buttons horizontal, history in grid layout
- Mobile: Stacked vertically, history as vertical list

---

### 2. Analysis in Progress

**User clicks "Analyze Security" or "Analyze Monitoring"**

**What happens:**
- URL validation occurs (must be valid GitHub public repo URL)
- If invalid: Error message appears below input field
- If valid: Transition to analysis screen

**Analysis screen shows:**
- Blurred/dimmed background of landing page
- Central modal/card with:
  - Animated loader (spinning, pulsing, or custom animation)
  - Progress text: "Analyzing [repository-name]..."
  - Sub-text rotating between:
    - "Cloning repository..."
    - "Scanning code structure..."
    - "Running AI analysis..."
    - "Generating recommendations..."
  - Repository URL displayed
  - Analysis type badge (Security/Monitoring)

**Duration:** ~30-60 seconds (synchronous processing)

**User actions:**
- Cannot cancel (MVP - no cancel button)
- Animation keeps them engaged

---

### 3. Results Dashboard

**Analysis completes successfully**

**What they see:**
- New page/view with results
- Header section:
  - Repository name and URL (clickable to GitHub)
  - Analysis type badge
  - Timestamp of analysis
  - "Analyze Again" button (returns to landing page)
  - "Share Results" button (optional - copy link)

**Results Content:**

**For Security Analysis:**
- Summary section:
  - Total issues found
  - Severity breakdown (Critical: X, High: X, Medium: X, Low: X)
- Issues list (grouped by severity):
  - Each issue card contains:
    - Severity badge (color-coded)
    - Issue title/category
    - Description of the vulnerability
    - Why it's problematic for AI-generated code
    - Claude Code-compatible prompt in copyable code block
    - "Copy Prompt" button

**For Monitoring Analysis:**
- Summary section:
  - Total recommendations
  - Categories covered (Analytics, Error Tracking, Business Metrics, etc.)
- Recommendations list (grouped by category):
  - Each recommendation card contains:
    - Category badge
    - Recommendation title
    - Description of the monitoring opportunity
    - Business value explanation
    - Claude Code-compatible prompt in copyable code block
    - "Copy Prompt" button

**User actions:**
- Scroll through results
- Copy individual prompts to clipboard
- Click "Analyze Again" to start new analysis
- Click repository link to view on GitHub
- Navigate back to home to see this in history

**Responsive behavior:**
- Desktop: Two-column layout for cards
- Mobile: Single column stack

---

### 4. Viewing History

**User clicks on a history card (from landing page)**

**What happens:**
- Navigates to results dashboard (same as #3)
- Shows the cached/saved results from that analysis
- Same layout and functionality as fresh analysis results

**User actions:**
- Same as Results Dashboard (#3)
- Can navigate back to landing page

---

## Edge Cases & Error States

### Invalid GitHub URL
- **Trigger:** User enters non-GitHub URL or malformed URL
- **Response:** Inline error message: "Please enter a valid public GitHub repository URL"
- **Recovery:** User corrects URL and tries again

### Repository Not Found / Private Repo
- **Trigger:** Repo doesn't exist or is private
- **Response:** Error modal after validation attempt
  - Message: "Unable to access repository. Please ensure it's public and the URL is correct."
  - "Try Again" button returns to landing page
- **Recovery:** User enters different repo

### Analysis Timeout / Server Error
- **Trigger:** OpenAI API timeout, network error, or server issue
- **Response:** Error modal during analysis
  - Message: "Analysis failed. Please try again in a moment."
  - Error details (optional, for debugging)
  - "Go Back" button returns to landing page
- **Recovery:** User retries

### No Issues/Recommendations Found
- **Trigger:** AI finds no issues or recommendations
- **Response:** Results page shows:
  - Success message: "Great news! No significant [security issues/monitoring gaps] detected."
  - Optional: "Your code looks solid for an AI-generated project!"
  - "Analyze Again" option
- **Recovery:** User can try other analysis type or different repo

---

## Session Management (Cookie-based)

### First Visit
- App generates anonymous user ID (UUID)
- Stored in browser cookie (30-day expiration)
- History section shows only 2 demo examples

### Returning Visit
- App reads cookie to identify user
- Loads previous analysis history from backend
- Displays up to last 10 analyses + 2 demo examples

### Cookie Cleared
- User treated as new visitor
- Previous history not accessible (no account system in MVP)

---

## Navigation Flow

```
Landing Page
    ├─> Enter URL + Click "Analyze Security"
    │   └─> Analysis Loading (30-60s)
    │       ├─> Security Results Dashboard
    │       │   └─> Click "Analyze Again" → Back to Landing Page
    │       └─> Error → Back to Landing Page
    │
    ├─> Enter URL + Click "Analyze Monitoring"
    │   └─> Analysis Loading (30-60s)
    │       ├─> Monitoring Results Dashboard
    │       │   └─> Click "Analyze Again" → Back to Landing Page
    │       └─> Error → Back to Landing Page
    │
    └─> Click History Card (Demo or Previous)
        └─> Cached Results Dashboard
            └─> Click "Analyze Again" → Back to Landing Page
```

---

## Key User Experience Principles

1. **Simplicity:** No authentication, no complex forms - just URL and two buttons
2. **Transparency:** Clear progress indicators during analysis
3. **Actionability:** Every result includes ready-to-use Claude Code prompts
4. **Responsiveness:** Works seamlessly on desktop and mobile
5. **Speed:** Synchronous processing with engaging animation (no perception of wait)
6. **Discoverability:** Demo examples show value immediately

---

## Success Metrics (Future)

- Time from landing to first analysis completion
- Copy-to-clipboard usage (prompt adoption)
- Return visitor rate (via cookies)
- Mobile vs desktop usage split
- Analysis type preference (Security vs Monitoring)
