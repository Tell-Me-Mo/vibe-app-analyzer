# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING**: Migrated from flutter_riverpod 2.6.1 to 3.0.3
  - Replaced `StateNotifier` with `Notifier` API across all providers
  - Replaced `StateNotifierProvider` with `NotifierProvider`
  - Migrated `AnalysisNotifier` to use new `Notifier<AnalysisState>` API
  - Migrated `HistoryNotifier` to use new `Notifier<List<AnalysisResult>>` API
  - Migrated `ValidationNotifier` to use new `Notifier<Map<String, dynamic>>` API
  - Moved service dependency injection from constructor to `build()` method
  - Services are now accessed via `ref.watch()` in the notifier's `build()` method

### Added
- **Riverpod 3.0 Feature: `ref.mounted` checks** - Added safety checks throughout async operations
  - Prevents state updates on disposed providers during long-running API calls
  - Protects against race conditions when users navigate away during analysis
  - Applied to both static code analysis and runtime analysis flows
  - Guards all async operations: GitHub API calls, OpenAI analysis, storage operations

- **Riverpod 3.0 Feature: Provider-level retry configuration** - Smart automatic retry for network failures
  - GitHub API: 2 retries with 2s, 4s backoff (skips 404/403 errors)
  - OpenAI API: 3 retries with 3s, 6s, 9s backoff (skips rate limits and auth errors)
  - Runtime Analysis: 2 retries with 2s, 4s backoff
  - Complements existing service-level retry logic for maximum reliability

### Technical Details
The migration to Riverpod 3.0 introduces the following changes:
- Notifiers no longer use constructor parameters for dependencies
- Dependencies are now declared as `late final` fields and initialized in the `build()` method
- The `build()` method returns the initial state instead of passing it to `super()`
- Providers are now created with simplified syntax: `NotifierProvider<T, S>(() => T())`
- Automatic retry functionality is now enabled by default for failing providers
- All providers use `==` for update filtering instead of `identical`
- **No test updates required** - `ProviderScope` API remains unchanged in Riverpod 3.0

### Improved
- **Reliability**: Provider-level retries reduce transient network failures
- **Stability**: `ref.mounted` guards prevent disposal-related crashes
- **User Experience**: Users less likely to encounter errors from temporary network issues

### Migration Testing
- ✅ All 118 unit and widget tests pass
- ✅ Flutter analyze shows no errors (only 2 minor unused variable warnings in test files)
- ✅ All existing functionality preserved
- ✅ New safety features work seamlessly with existing error handling

For more information about Riverpod 3.0 changes, see the [official migration guide](https://riverpod.dev/docs/3.0_migration).

## [1.0.0] - Initial Release

### Added
- AI-powered code analyzer for security vulnerabilities
- Dual-mode analysis: GitHub repository static analysis and live application runtime analysis
- Credit-based monetization system with packages (10, 25, 50, 100 credits)
- AI-powered fix validation feature (1 credit per validation)
- Integration with OpenAI for intelligent code analysis
- Integration with Supabase for authentication and user management
- Support for Google Sign-In and Apple Sign-In
- In-app purchases via RevenueCat
- Persistent local storage with SharedPreferences (encrypted)
- Secure credential storage
- Analysis history tracking
- GitHub API integration for repository analysis
- Monitoring recommendations for production applications
- Security issue severity classification (critical, high, medium, low)
- Comprehensive test coverage for models, services, and widgets
