import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/credit_package.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../widgets/common/credits_indicator.dart';

class CreditsPage extends ConsumerStatefulWidget {
  const CreditsPage({super.key});

  @override
  ConsumerState<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends ConsumerState<CreditsPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handlePurchase(CreditPackage package) async {
    final authService = ref.read(authServiceProvider);

    // Check if user is signed in
    if (!authService.isSignedIn) {
      // Show dialog to sign in
      if (!mounted) return;
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to sign in to purchase credits. Your purchases will be synced across devices.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60A5FA),
                foregroundColor: const Color(0xFF0F172A),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );

      if (shouldSignIn == true && mounted) {
        context.go('/auth');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // Initialize payment service with user ID
      await paymentService.initialize(authService.currentUser!.id);

      // Get available packages
      final packages = await paymentService.getAvailablePackages();

      // Find matching package
      final revenueCatPackage = packages.firstWhere(
        (p) => p.identifier.contains(package.id),
        orElse: () => packages.first,
      );

      // Purchase the package
      final success = await paymentService.purchasePackage(revenueCatPackage);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully purchased ${package.credits} credits!'),
            backgroundColor: const Color(0xFF34D399),
          ),
        );
      }
    } on PaymentException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Purchase failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      const CreditsIndicator(),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Get More Credits',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 32,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the perfect package for your needs',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF87171).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFF87171),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Color(0xFFF87171)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Packages grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800
                          ? 4
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: CreditPackages.all.length,
                        itemBuilder: (context, index) {
                          final package = CreditPackages.all[index];
                          return _buildPackageCard(package);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF60A5FA),
                          size: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Each analysis costs 5 credits',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Credits never expire and are synced across all your devices',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(CreditPackage package) {
    return Container(
      decoration: BoxDecoration(
        gradient: package.isPopular
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              )
            : null,
        color: package.isPopular ? null : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: package.isPopular
              ? const Color(0xFF60A5FA)
              : const Color(0xFF334155),
          width: package.isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Popular badge
          if (package.isPopular)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  package.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  package.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                ),
                const Spacer(),

                // Credits
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Color(0xFFFCD34D),
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${package.credits}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'credits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price
                Text(
                  package.priceDisplay,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (package.savings != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Save ${package.savings}%',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Buy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _handlePurchase(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: package.isPopular
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: package.isPopular
                            ? BorderSide.none
                            : const BorderSide(
                                color: Color(0xFF334155),
                              ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFF1F5F9),
                            ),
                          )
                        : const Text(
                            'Purchase',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
