import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class AuthButton extends ConsumerWidget {
  const AuthButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final authService = ref.watch(authServiceProvider);

    return authStateAsync.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          // Check if user is anonymous (guest)
          if (authService.isAnonymous) {
            return _buildGuestButton(context);
          }

          // Show profile button for authenticated users
          return userProfileAsync.when(
            data: (profile) {
              if (profile == null) return _buildLoginButton(context);

              return InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF60A5FA),
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                _getInitials(profile),
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getDisplayName(profile),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => _buildLoginButton(context),
            error: (error, stackTrace) => _buildLoginButton(context),
          );
        } else {
          return _buildLoginButton(context);
        }
      },
      loading: () => _buildLoginButton(context),
      error: (error, stackTrace) => _buildLoginButton(context),
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/auth'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFF94A3B8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 18),
          const SizedBox(width: 8),
          Text(
            'Guest',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/auth'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF60A5FA),
        foregroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.login, size: 18),
          const SizedBox(width: 8),
          Text(
            'Sign In',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
          ),
        ],
      ),
    );
  }

  String _getInitials(dynamic profile) {
    // Try display name first
    if (profile.displayName != null && profile.displayName!.isNotEmpty) {
      return profile.displayName!.substring(0, 1).toUpperCase();
    }

    // Try email if not empty
    if (profile.email.isNotEmpty) {
      return profile.email.substring(0, 1).toUpperCase();
    }

    // Fallback to 'G' for Guest
    return 'G';
  }

  String _getDisplayName(dynamic profile) {
    // Try display name first
    if (profile.displayName != null && profile.displayName!.isNotEmpty) {
      return profile.displayName!;
    }

    // Try email username if email is not empty
    if (profile.email.isNotEmpty) {
      return profile.email.split('@')[0];
    }

    // Fallback to 'Guest'
    return 'Guest';
  }
}
