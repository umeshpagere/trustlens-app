export function calculateCredibilityScore(riskLevel) {
  let credibilityScore = 100;

  if (riskLevel === "medium") {
    credibilityScore -= 30;
  } else if (riskLevel === "high") {
    credibilityScore -= 60;
  }

  // Ensure score is between 0 and 100
  credibilityScore = Math.max(0, Math.min(100, credibilityScore));

  let verdict;
  if (credibilityScore >= 70) {
    verdict = "Reliable";
  } else if (credibilityScore >= 40) {
    verdict = "Suspicious";
  } else {
    verdict = "Unreliable";
  }

  return {
    credibilityScore,
    verdict
  };
}

/**
 * Calculates final credibility score by combining text and image analysis
 * @param {Object} textAnalysis - Text analysis result with credibilityScore
 * @param {string|Object} imageAnalysis - Image analysis result or "skipped"
 * @returns {Object} Final score and verdict
 */
export function calculateFinalScore(textAnalysis, imageAnalysis) {
  // Handle missing textAnalysis
  if (!textAnalysis || typeof textAnalysis !== "object") {
    return {
      finalScore: 100,
      finalVerdict: "Reliable"
    };
  }

  // Start with text analysis credibility score
  // Use nullish coalescing to handle 0 as a valid score
  let finalScore = (textAnalysis.credibilityScore !== undefined && textAnalysis.credibilityScore !== null) 
    ? textAnalysis.credibilityScore 
    : 100;

  // Handle image analysis
  // Check if image analysis was skipped (string "skipped" or object with status "skipped")
  const isSkipped = imageAnalysis === "skipped" || 
                    (imageAnalysis && imageAnalysis.status === "skipped");

  if (!isSkipped && imageAnalysis && typeof imageAnalysis === "object") {
    // Phase 5: Use image credibility score if available
    if (imageAnalysis.credibilityScore !== undefined) {
      // Combine text and image scores (weighted average: 60% text, 40% image)
      const textWeight = 0.6;
      const imageWeight = 0.4;
      finalScore = Math.round(
        (textAnalysis.credibilityScore * textWeight) + 
        (imageAnalysis.credibilityScore * imageWeight)
      );
    } else {
      // Fallback to Phase 4 logic for backward compatibility
      // Check if image was reused (from tracing.reusedImage or direct reused property)
      const isReused = imageAnalysis.reused === true || 
                       (imageAnalysis.tracing && imageAnalysis.tracing.reusedImage === true);
      
      if (isReused) {
        finalScore -= 25;
      }

      // Check metadata risk (from metadataRisk property or derive from metadata)
      const hasMetadataRisk = imageAnalysis.metadataRisk === true ||
                             (imageAnalysis.metadata && 
                              (imageAnalysis.metadata.possibleScreenshot === true || 
                               imageAnalysis.metadata.hasExif === true));

      if (hasMetadataRisk) {
        finalScore -= 15;
      }
    }
  }

  // Ensure score is between 0 and 100
  finalScore = Math.max(0, Math.min(100, finalScore));

  // Generate final verdict (aligned with textAnalysis thresholds)
  let finalVerdict;
  if (finalScore >= 75) {
    finalVerdict = "Reliable";
  } else if (finalScore >= 40) {
    finalVerdict = "Questionable";
  } else {
    finalVerdict = "High Risk";
  }

  return {
    finalScore,
    finalVerdict
  };
}

