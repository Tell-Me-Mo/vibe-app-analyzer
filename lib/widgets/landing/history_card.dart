import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/analysis_result.dart';

class HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final isSecurityAnalysis = result.analysisType.displayName == 'Security';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSecurityAnalysis
                          ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                          : [const Color(0xFF34D399), const Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSecurityAnalysis ? Icons.security : Icons.show_chart,
                    color: const Color(0xFF0F172A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (result.isDemo)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFBBF24),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (result.isDemo) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.repositoryName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF1F5F9),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSecurityAnalysis
                                  ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                  : const Color(0xFF34D399).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result.analysisType.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSecurityAnalysis
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF34D399),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${result.summary.total} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(result.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF475569),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
