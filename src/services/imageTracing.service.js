/**
 * Traces image to determine likelihood of reuse
 * @param {Buffer} imageBuffer - The image buffer to trace
 * @returns {Object} Tracing analysis result
 */
export function traceImage(imageBuffer) {
  // Handle empty buffer
  if (!imageBuffer || imageBuffer.length === 0) {
    return {
      reusedLikelihood: "low",
      reason: "Empty image buffer"
    };
  }

  const bufferSize = imageBuffer.length;
  const sizeInKB = bufferSize / 1024;

  // Small images are more likely to be reused (common stock photos, memes, etc.)
  if (sizeInKB < 50) {
    return {
      reusedLikelihood: "high",
      reason: "Small file size suggests potential reuse"
    };
  }

  return {
    reusedLikelihood: "low",
    reason: "File size indicates original content"
  };
}


