import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

/// Home screen shown when the app is opened directly (not via Share Sheet).
/// Explains how to use TrustLens and shows backend connection status.
class HomeScreen extends StatelessWidget {
  final bool isBackendConnected;
  final VoidCallback onRetryConnection;

  const HomeScreen({
    super.key,
    required this.isBackendConnected,
    required this.onRetryConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrustLens'),
        actions: [
          IconButton(
            tooltip: 'Share sample',
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              Share.share(
                'Check this with TrustLens: https://trustlens.ai',
                subject: 'TrustLens demo share',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '\u{1F6E1}\u{FE0F}',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TrustLens',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI-powered credibility assistant',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Connection status
              _ConnectionStatus(
                isConnected: isBackendConnected,
                onRetry: onRetryConnection,
              ),
              const SizedBox(height: 32),

              // How to use
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20),
                    _StepItem(
                      number: '1',
                      title: 'Find content to verify',
                      description:
                          'Open any app \u2014 Instagram, X, WhatsApp, YouTube, or a browser.',
                    ),
                    _StepItem(
                      number: '2',
                      title: 'Tap Share',
                      description:
                          'Use the Share button on any post, image, or link.',
                    ),
                    _StepItem(
                      number: '3',
                      title: 'Select TrustLens',
                      description:
                          'Choose TrustLens from the Share Sheet. Analysis starts instantly.',
                    ),
                    _StepItem(
                      number: '4',
                      title: 'Review results',
                      description:
                          'See the credibility score, risk level, and tap "Learn More" for a deep analysis.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Privacy notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.riskLowBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.riskLow.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Text('\u{1F512}', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Privacy-first: TrustLens only analyzes content you explicitly share. No background access, no data collection.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onRetry;

  const _ConnectionStatus({required this.isConnected, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.riskLowBg : AppColors.riskHighBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error_outline,
            color: isConnected ? AppColors.riskLow : AppColors.riskHigh,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isConnected
                  ? 'Backend connected \u2014 ready to analyze'
                  : 'Backend not reachable. Ensure the server is running.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isConnected ? AppColors.riskLow : AppColors.riskHigh,
              ),
            ),
          ),
          if (!isConnected)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.riskHigh),
            ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
