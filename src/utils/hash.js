import crypto from "crypto";

/**
 * Generates a SHA-256 hash for a given buffer.
 * Used for deterministic image identification without storing raw pixels.
 * @param {Buffer} buffer - The image buffer to hash
 * @returns {string} The hex-encoded hash
 */
export function generateImageHash(buffer) {
  if (!buffer || !Buffer.isBuffer(buffer)) {
    throw new Error("Invalid buffer provided for hashing");
  }
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

/**
 * Generates a SHA-256 hash for a given text string.
 * Normalizes text (lowercase, trimmed) for better matching.
 * @param {string} text - The text content to hash
 * @returns {string} The hex-encoded hash
 */
export function generateTextHash(text) {
  if (typeof text !== "string") {
    throw new Error("Invalid text provided for hashing");
  }
  const normalized = text.trim().toLowerCase();
  return crypto.createHash("sha256").update(normalized).digest("hex");
}
