import { CosmosClient } from "@azure/cosmos";
import dotenv from "dotenv";

dotenv.config();

const endpoint = process.env.COSMOS_ENDPOINT;
const key = process.env.COSMOS_KEY;
const databaseId = "trustlensDB";
const containerId = "analysis_records";

// Initialize Cosmos Client only if credentials are provided
let container = null;

if (endpoint && key) {
  try {
    const client = new CosmosClient({ endpoint, key });
    const database = client.database(databaseId);
    container = database.container(containerId);
    console.log("✅ Cosmos DB client initialized");
  } catch (error) {
    console.error("❌ Failed to initialize Cosmos DB client:", error.message);
  }
} else {
  console.warn("⚠️ Cosmos DB credentials missing. Storage service will operate in mock mode.");
}

/**
 * Stores an analysis result in Cosmos DB.
 * Uses hashes to identify content without storing raw user data.
 * This protects user privacy by ensuring that sensitive images or text
 * are never persisted in their original form.
 * 
 * @param {Object} params - Storage parameters
 * @param {string} params.hash - Unique hash of the content
 * @param {string} params.type - Content type ("image" or "text")
 * @param {Object} params.analysis - The analysis result to store
 * @returns {Promise<Object>} The stored document
 */
export async function storeAnalysis({ hash, type, analysis }) {
  if (!container) {
    console.warn("Storage skipped: Cosmos DB container not initialized");
    return null;
  }

  const document = {
    id: hash, // Use hash as ID for direct lookup
    hash: hash,
    type: type,
    analysis: analysis,
    createdAt: new Date().toISOString(),
    responsibleAI: "TrustLens Privacy Shield - No raw content stored"
  };

  try {
    const { resource } = await container.items.create(document);
    return resource;
  } catch (error) {
    // If it already exists (Conflict 409), we just return null or handle accordingly
    if (error.code === 409) {
      console.log(`Document with hash ${hash} already exists.`);
      return null;
    }
    console.error("Error storing analysis:", error.message);
    throw error;
  }
}

/**
 * Finds an analysis result by its content hash.
 * This allows us to reuse results for identical content (Image Tracing).
 * 
 * @param {string} hash - The hash to search for
 * @returns {Promise<Object|null>} The stored analysis or null if not found
 */
export async function findAnalysisByHash(hash) {
  if (!container) return null;

  try {
    const { resource } = await container.item(hash, hash).read();
    return resource || null;
  } catch (error) {
    // If not found (404), return null
    if (error.code === 404) return null;
    console.error("Error finding analysis by hash:", error.message);
    return null;
  }
}
