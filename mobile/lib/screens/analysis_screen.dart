import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/share_intent_service.dart';
import '../theme/app_theme.dart';
import '../widgets/analysis_widgets.dart';
import 'detailed_analysis_screen.dart';

/// Shown as a bottom-sheet-style screen when content arrives via Share Sheet.
/// Mirrors the browser extension overlay: score gauge, risk pill, bullet points,
/// Learn More / Dismiss buttons.
class AnalysisScreen extends StatefulWidget {
  final SharedContent sharedContent;

  const AnalysisScreen({super.key, required this.sharedContent});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _api = ApiService();
  bool _loading = true;
  AnalysisResponse? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    try {
      final content = widget.sharedContent;

      // If an image file path was shared, we can't send a local path to the
      // backend (it expects a URL). Show a message instead.
      if (content.imagePath != null && content.text == null && content.imageUrl == null) {
        setState(() {
          _loading = false;
          _error = 'Shared image received. For best results, share a link or text from the original post.';
        });
        return;
      }

      final result = await _api.analyze(
        text: content.text,
        imageUrl: content.imageUrl,
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _result = result;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Connection failed. Is the backend running?';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait while analysis completes')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: _buildSheet(context),
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('\u{1F6E1}\u{FE0F}', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TrustLens',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'AI-powered credibility assistant',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content preview
            _buildPreview(),
            const SizedBox(height: 20),

            // Main content: loading / error / results
            if (_loading) _buildLoading(),
            if (_error != null) _buildError(),
            if (_result != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final content = widget.sharedContent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.remove_red_eye_outlined,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Content being analyzed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (content.text != null)
            Text(
              content.text!.length > 200
                  ? '${content.text!.substring(0, 200)}...'
                  : content.text!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          if (content.imageUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                content.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 60,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Text('Image URL shared',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
          ],
          if (content.imagePath != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(content.imagePath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 60,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Text('Shared image',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      children: [
        SizedBox(height: 24),
        SpinKitDoubleBounce(color: AppColors.primary, size: 50),
        SizedBox(height: 16),
        Text(
          'Analyzing credibility...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.riskHighBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _error!,
            style: const TextStyle(
              color: AppColors.riskHigh,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Dismiss',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final result = _result!;
    final score = result.finalResult.finalScore;
    final risk = result.finalResult.riskLevel;

    // Gather bullet points like the extension does
    final points = <String>[];
    if (result.textAnalysis != null) {
      points.addAll(result.textAnalysis!.riskKeywordsFound);
    }
    if (result.imageAnalysis?.llmAnalysis != null) {
      points.addAll(result.imageAnalysis!.llmAnalysis!.visualRedFlags);
    }
    if (points.isEmpty && risk != 'low') {
      final explanation = result.textAnalysis?.explanation ??
          result.imageAnalysis?.llmAnalysis?.explanation ??
          '';
      points.addAll(
        explanation
            .split('.')
            .where((s) => s.trim().length > 10)
            .take(2)
            .map((s) => s.trim()),
      );
    }
    if (points.isEmpty) {
      points.addAll(['Content verified', 'No major risk indicators found']);
    }

    return Column(
      children: [
        // Score gauge
        CredibilityGauge(score: score),
        const SizedBox(height: 16),

        // Risk pill
        RiskPill(riskLevel: risk),
        const SizedBox(height: 16),

        // Bullet points
        ...points.take(3).map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('\u2022 ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailedAnalysisScreen(result: result),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('Learn More',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.riskLow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Dismiss',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E7EB),
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
