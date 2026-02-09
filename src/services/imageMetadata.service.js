/**
 * Analyzes image metadata to determine credibility risk
 * @param {Buffer} imageBuffer - The image buffer to analyze
 * @returns {Object} Metadata analysis result
 */
export function analyzeImageMetadata(imageBuffer) {
  // Handle empty buffer
  if (!imageBuffer || imageBuffer.length === 0) {
    return {
      hasMetadata: false,
      possibleAI: false,
      metadataRisk: "low"
    };
  }

  const bufferSize = imageBuffer.length;
  const sizeInKB = bufferSize / 1024;
  const sizeInMB = bufferSize / (1024 * 1024);

  // Determine if image might be AI-generated (very small files often indicate AI)
  const possibleAI = sizeInKB < 30;

  // Determine metadata risk based on file size
  let metadataRisk = "low";
  if (sizeInMB > 5) {
    metadataRisk = "medium";
  }

  return {
    hasMetadata: bufferSize > 0,
    possibleAI,
    metadataRisk
  };
}


