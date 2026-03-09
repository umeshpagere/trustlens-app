/// Models matching the Flask backend POST /api/analyze response.
///
/// Response shape:
/// {
///   "success": true,
///   "textAnalysis": { ... },
///   "imageAnalysis": { ... },
///   "finalResult": { "finalScore": int, "finalVerdict": string },
///   "hash": string?,
///   "reused": bool?
/// }
library;

class AnalysisResponse {
  final bool success;
  final TextAnalysis? textAnalysis;
  final ImageAnalysis? imageAnalysis;
  final FinalResult finalResult;
  final String? hash;
  final bool reused;

  AnalysisResponse({
    required this.success,
    this.textAnalysis,
    this.imageAnalysis,
    required this.finalResult,
    this.hash,
    this.reused = false,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      success: json['success'] ?? false,
      textAnalysis: json['textAnalysis'] != null &&
              json['textAnalysis']['status'] != 'skipped'
          ? TextAnalysis.fromJson(json['textAnalysis'])
          : null,
      imageAnalysis: json['imageAnalysis'] != null &&
              json['imageAnalysis']['status'] != 'skipped'
          ? ImageAnalysis.fromJson(json['imageAnalysis'])
          : null,
      finalResult: FinalResult.fromJson(json['finalResult']),
      hash: json['hash'],
      reused: json['reused'] ?? false,
    );
  }
}

class TextAnalysis {
  final String riskLevel;
  final List<String> riskKeywordsFound;
  final int credibilityScore;
  final String verdict;
  final String explanation;

  TextAnalysis({
    required this.riskLevel,
    required this.riskKeywordsFound,
    required this.credibilityScore,
    required this.verdict,
    required this.explanation,
  });

  factory TextAnalysis.fromJson(Map<String, dynamic> json) {
    return TextAnalysis(
      riskLevel: json['riskLevel'] ?? 'medium',
      riskKeywordsFound:
          List<String>.from(json['riskKeywordsFound'] ?? []),
      credibilityScore: json['credibilityScore'] ?? 50,
      verdict: json['verdict'] ?? 'Questionable',
      explanation: json['explanation'] ?? '',
    );
  }
}

class ImageAnalysis {
  final String status;
  final int credibilityScore;
  final String verdict;
  final LlmImageAnalysis? llmAnalysis;

  ImageAnalysis({
    required this.status,
    required this.credibilityScore,
    required this.verdict,
    this.llmAnalysis,
  });

  factory ImageAnalysis.fromJson(Map<String, dynamic> json) {
    return ImageAnalysis(
      status: json['status'] ?? 'skipped',
      credibilityScore: json['credibilityScore'] ?? 50,
      verdict: json['verdict'] ?? 'Questionable',
      llmAnalysis: json['llmAnalysis'] != null
          ? LlmImageAnalysis.fromJson(json['llmAnalysis'])
          : null,
    );
  }
}

class LlmImageAnalysis {
  final String riskLevel;
  final String verdict;
  final int credibilityScore;
  final String extractedText;
  final String textVerification;
  final String imageContent;
  final String conveyedMessage;
  final String veracityCheck;
  final String explanation;
  final List<String> visualRedFlags;
  final int aiGeneratedProbability;

  LlmImageAnalysis({
    required this.riskLevel,
    required this.verdict,
    required this.credibilityScore,
    required this.extractedText,
    required this.textVerification,
    required this.imageContent,
    required this.conveyedMessage,
    required this.veracityCheck,
    required this.explanation,
    required this.visualRedFlags,
    required this.aiGeneratedProbability,
  });

  factory LlmImageAnalysis.fromJson(Map<String, dynamic> json) {
    return LlmImageAnalysis(
      riskLevel: json['riskLevel'] ?? 'medium',
      verdict: json['verdict'] ?? 'Questionable',
      credibilityScore: json['credibilityScore'] ?? 50,
      extractedText: json['extractedText'] ?? '',
      textVerification: json['textVerification'] ?? '',
      imageContent: json['imageContent'] ?? '',
      conveyedMessage: json['conveyedMessage'] ?? '',
      veracityCheck: json['veracityCheck'] ?? '',
      explanation: json['explanation'] ?? '',
      visualRedFlags: List<String>.from(json['visualRedFlags'] ?? []),
      aiGeneratedProbability: json['aiGeneratedProbability'] ?? 0,
    );
  }
}

class FinalResult {
  final int finalScore;
  final String finalVerdict;

  /// Derived from finalScore for UI display.
  String get riskLevel {
    if (finalScore >= 75) return 'low';
    if (finalScore >= 40) return 'medium';
    return 'high';
  }

  FinalResult({
    required this.finalScore,
    required this.finalVerdict,
  });

  factory FinalResult.fromJson(Map<String, dynamic> json) {
    return FinalResult(
      finalScore: json['finalScore'] ?? 50,
      finalVerdict: json['finalVerdict'] ?? 'Questionable',
    );
  }
}
