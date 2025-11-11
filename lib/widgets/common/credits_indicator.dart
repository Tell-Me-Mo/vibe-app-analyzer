import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/credits_service.dart';

class CreditsIndicator extends ConsumerWidget {
  const CreditsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsAsync = ref.watch(creditsProvider);

    return creditsAsync.when(
      data: (credits) => _buildIndicator(context, credits),
      loading: () => _buildIndicator(context, 0),
      error: (error, stackTrace) => _buildIndicator(context, 0),
    );
  }

  Widget _buildIndicator(BuildContext context, int credits) {
    // Determine color based on credits
    Color color;
    if (credits >= 20) {
      color = const Color(0xFF34D399); // Green
    } else if (credits >= 10) {
      color = const Color(0xFF60A5FA); // Blue
    } else if (credits >= 5) {
      color = const Color(0xFFFCD34D); // Yellow
    } else {
      color = const Color(0xFFF87171); // Red
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.go('/credits');
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$credits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'credits',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline,
              color: color.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
