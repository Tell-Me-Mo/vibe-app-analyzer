# App Analyzer - Setup Guide

## Overview
App Analyzer is a Flutter Web application that analyzes AI-generated code repositories for security vulnerabilities and business monitoring opportunities.

## Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK 3.9.0 or higher
- OpenAI API key

## Installation Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure OpenAI API Key
Edit `lib/config/app_config.dart` and replace `YOUR_OPENAI_API_KEY_HERE` with your actual OpenAI API key:

```dart
static const String openaiApiKey = 'sk-...your-key-here...';
```

**Important Security Note:** For production, never commit API keys to your repository. Use environment variables or a backend proxy instead.

### 3. Run the App

#### For Web (Recommended)
```bash
flutter run -d chrome
```

Or build for production:
```bash
flutter build web --release
```

The built files will be in `build/web/` directory.

#### For Desktop (Optional)
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart              # Configuration (API keys, constants)
├── models/
│   ├── analysis_type.dart           # Analysis type enum
│   ├── analysis_result.dart         # Main result model
│   ├── security_issue.dart          # Security issue model
│   ├── monitoring_recommendation.dart # Monitoring recommendation model
│   └── severity.dart                # Severity enum
├── services/
│   ├── github_service.dart          # GitHub API integration
│   ├── openai_service.dart          # OpenAI API integration
│   └── storage_service.dart         # Local storage (history)
├── providers/
│   ├── analysis_provider.dart       # Analysis state management
│   └── history_provider.dart        # History state management
├── pages/
│   ├── landing_page.dart            # Home page
│   ├── analysis_loading_page.dart   # Loading screen during analysis
│   └── results_page.dart            # Results dashboard
├── widgets/
│   ├── common/                      # Reusable widgets
│   ├── landing/                     # Landing page widgets
│   └── results/                     # Results page widgets
├── data/
│   └── demo_data.dart               # Demo example data
├── utils/
│   └── validators.dart              # Input validation utilities
├── app.dart                         # App routing configuration
└── main.dart                        # App entry point
```

## Features

### Current Features (MVP)
- ✅ Analyze public GitHub repositories
- ✅ Two analysis modes: Security & Monitoring
- ✅ AI-powered analysis using GPT-4o mini
- ✅ Claude Code-compatible prompts
- ✅ Analysis history (cookie-based)
- ✅ Demo examples pre-loaded
- ✅ Responsive design (desktop & mobile)
- ✅ Copy prompts to clipboard

### Analysis Types

#### Security Analysis
Identifies common vulnerabilities in AI-generated code:
- Hardcoded secrets/API keys
- Missing input validation
- Insecure authentication patterns
- SQL injection risks
- XSS vulnerabilities
- Insecure API endpoints
- Missing CORS/security headers

#### Monitoring Analysis
Identifies missing business monitoring opportunities:
- User action tracking (signups, purchases, clicks)
- Conversion funnel metrics
- Business KPI tracking
- Custom event logging
- User behavior analytics
- Performance monitoring (API latency, load times)

## Usage

1. **Enter Repository URL**
   - Paste a public GitHub repository URL (e.g., `https://github.com/username/repo`)

2. **Choose Analysis Type**
   - Click "Analyze Security" for security vulnerabilities
   - Click "Analyze Monitoring" for business monitoring recommendations

3. **Wait for Analysis**
   - The app will fetch repository code and analyze it (~30-60 seconds)

4. **View Results**
   - See categorized issues or recommendations
   - Copy Claude Code prompts to implement fixes

5. **History**
   - View previous analyses on the landing page
   - Demo examples are pre-loaded for reference

## Deployment

### Firebase Hosting
```bash
flutter build web --release
firebase init hosting
firebase deploy
```

### Vercel
```bash
flutter build web --release
vercel --prod
```

### Netlify
```bash
flutter build web --release
netlify deploy --prod --dir=build/web
```

## Troubleshooting

### Build Issues
If you encounter build errors:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

### API Rate Limits
- GitHub API: 60 requests/hour (unauthenticated), 5000/hour (with token)
- OpenAI API: Depends on your plan

To add GitHub token (optional, for higher rate limits):
```dart
// In lib/services/github_service.dart
_dio = Dio(BaseOptions(
  baseUrl: AppConfig.githubApiUrl,
  headers: {
    'Accept': 'application/vnd.github.v3+json',
    'Authorization': 'Bearer YOUR_GITHUB_TOKEN', // Add this
  },
));
```

### CORS Issues
If you encounter CORS errors when calling APIs from web:
- For production: Use a backend proxy to handle API calls
- For development: Use browser extensions like "CORS Unblock" (not recommended for production)

## Security Considerations

### API Key Management
- **Never commit API keys to Git**
- For production, implement a backend proxy:
  - Flutter Web → Your Backend → OpenAI/GitHub APIs
  - Store API keys securely on backend
  - Add authentication to your backend

### Data Privacy
- Analysis history stored locally (browser storage)
- No user data sent to external services except:
  - Repository URLs to GitHub API
  - Code content to OpenAI API

## Performance Optimization

### Reducing Bundle Size
```bash
flutter build web --web-renderer canvaskit --release
```

### Caching
- GitHub API responses are fetched on-demand
- Analysis results cached locally
- Consider adding service worker for offline support

## Future Enhancements (Not in MVP)

- User authentication (save history across devices)
- Private repository support (GitHub OAuth)
- Scheduled re-analysis
- Export reports as PDF
- API for programmatic access
- Custom analysis rules
- Multi-language support

## Support

For issues or questions:
1. Check the documentation files:
   - `USER_JOURNEY.md` - Detailed user flows
   - `HLD.md` - High-level design documentation
2. Review the code comments
3. Check Flutter/Dart documentation

## License

This is an MVP project. Add your license here.
