/**
 * Calculates image credibility score based on metadata and tracing analysis
 * @param {Object} metadata - Metadata analysis result
 * @param {Object} tracing - Tracing analysis result
 * @returns {Object} Image credibility score and verdict
 */
export function calculateImageCredibility(metadata, tracing) {
  // Start with base score
  let score = 100;

  // Apply metadata risk penalties
  if (metadata && metadata.metadataRisk) {
    if (metadata.metadataRisk === "medium") {
      score -= 20;
    } else if (metadata.metadataRisk === "high") {
      score -= 40;
    }
  }

  // Apply reuse likelihood penalties
  if (tracing && tracing.reusedLikelihood) {
    if (tracing.reusedLikelihood === "medium") {
      score -= 20;
    } else if (tracing.reusedLikelihood === "high") {
      score -= 40;
    }
  }

  // Clamp score between 0 and 100
  score = Math.max(0, Math.min(100, score));

  // Determine verdict based on score
  let verdict;
  if (score >= 70) {
    verdict = "Reliable";
  } else if (score >= 40) {
    verdict = "Questionable";
  } else {
    verdict = "High Risk";
  }

  return {
    score,
    verdict
  };
}





