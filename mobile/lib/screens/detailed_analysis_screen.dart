import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/analysis_widgets.dart';

/// Full-screen detailed analysis — mirrors the browser extension's
/// "Learn More" expanded view with text analysis, image analysis,
/// risk keywords, AI explanation, and image-specific breakdowns.
class DetailedAnalysisScreen extends StatelessWidget {
  final AnalysisResponse result;

  const DetailedAnalysisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.finalResult.finalScore;
    final risk = result.finalResult.riskLevel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detailed Analysis',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            // Final verdict card
            _buildVerdictCard(score, risk),
            const SizedBox(height: 20),

            // Text analysis section
            if (result.textAnalysis != null)
              _buildTextAnalysis(result.textAnalysis!),

            // Image analysis section
            if (result.imageAnalysis != null)
              _buildImageAnalysis(result.imageAnalysis!),

            // Cache info
            if (result.reused) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cached, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Text(
                      'Result loaded from cache',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerdictCard(int score, String risk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
      child: Column(
        children: [
          CredibilityGauge(score: score, size: 140),
          const SizedBox(height: 16),
          RiskPill(riskLevel: risk),
          const SizedBox(height: 12),
          Text(
            result.finalResult.finalVerdict,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAnalysis(TextAnalysis ta) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SectionCard(
          title: 'Text Analysis',
          icon: '\u{1F4DD}',
          accentColor: AppColors.riskColor(ta.riskLevel),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Risk Level', ta.riskLevel.toUpperCase()),
              _infoRow('Credibility', '${ta.credibilityScore}/100'),
              _infoRow('Verdict', ta.verdict),
              if (ta.riskKeywordsFound.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Risk Keywords Found:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ta.riskKeywordsFound
                      .map((k) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.riskHighBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.riskHigh,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
              if (ta.riskKeywordsFound.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppColors.riskLow),
                      SizedBox(width: 6),
                      Text(
                        'No risk keywords found',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.riskLow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (ta.explanation.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EBFF),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(
                        color: AppColors.aiPurple,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Explanation',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.aiPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ta.explanation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageAnalysis(ImageAnalysis ia) {
    final llm = ia.llmAnalysis;

    return Column(
      children: [
        const SizedBox(height: 16),
        SectionCard(
          title: 'Image Analysis',
          icon: '\u{1F5BC}\u{FE0F}',
          accentColor: AppColors.aiPurple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Credibility', '${ia.credibilityScore}/100'),
              _infoRow('Verdict', ia.verdict),

              if (llm != null) ...[
                const SizedBox(height: 16),
                // AI visual analysis explanation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EBFF),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(color: AppColors.aiPurple, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Visual Analysis',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.aiPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        llm.explanation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Visual red flags
                const SizedBox(height: 12),
                const Text(
                  'Visual Red Flags:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (llm.visualRedFlags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: llm.visualRedFlags
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.riskHighBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                f,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.riskHigh,
                                ),
                              ),
                            ))
                        .toList(),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppColors.riskLow),
                      SizedBox(width: 6),
                      Text(
                        'No visual red flags detected',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.riskLow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                // AI generation probability
                const SizedBox(height: 12),
                _infoRow('AI Generated Probability',
                    '${llm.aiGeneratedProbability}%'),

                // Detailed breakdowns
                if (llm.imageContent.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _detailBlock('Image Content', llm.imageContent),
                ],
                if (llm.conveyedMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailBlock('Conveyed Message', llm.conveyedMessage),
                ],
                if (llm.extractedText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailBlock('Extracted Text', llm.extractedText),
                ],
                if (llm.textVerification.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailBlock('Text Verification', llm.textVerification),
                ],
                if (llm.veracityCheck.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailBlock('Veracity Check', llm.veracityCheck),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
