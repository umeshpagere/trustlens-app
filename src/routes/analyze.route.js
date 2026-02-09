import express from "express";
import { z } from "zod";
import { analyzePostSchema } from "../models/post.schema.js";
import { analyzeTextWithLLM } from "../services/llmAnalysis.service.js";
import { calculateFinalScore } from "../services/scoring.service.js";
import { downloadImage } from "../utils/fetchImage.js";
import { analyzeImageMetadata } from "../services/imageMetadata.service.js";
import { traceImage } from "../services/imageTracing.service.js";
import { calculateImageCredibility } from "../services/imageScoring.service.js";
import { generateImageHash, generateTextHash } from "../utils/hash.js";
import { storeAnalysis, findAnalysisByHash } from "../services/analysisStorage.service.js";

const router = express.Router();

// Valid verdict values
const VALID_VERDICTS = ["Reliable", "Questionable", "High Risk"];

// GET handler - provide API information
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "TrustLens Analyze API",
    endpoint: "/api/analyze",
    method: "POST",
    description: "Analyze text and images for misinformation risk assessment",
    requestBody: {
      text: {
        type: "string",
        required: true,
        minLength: 5,
        description: "Text content to analyze"
      },
      imageUrl: {
        type: "string",
        required: false,
        format: "url",
        description: "Optional image URL to analyze"
      }
    },
    example: {
      text: "This is a sample text to analyze for misinformation",
      imageUrl: "https://example.com/image.jpg"
    }
  });
});

/**
 * Normalizes verdict to only allow valid values
 * @param {string} verdict - The verdict to normalize
 * @returns {string} Normalized verdict
 */
function normalizeVerdict(verdict) {
  if (typeof verdict === "string" && VALID_VERDICTS.includes(verdict)) {
    return verdict;
  }
  return "High Risk";
}

router.post("/", async (req, res, next) => {
  try {
    console.log("📥 /api/analyze route hit");
    // Validate request
    const validatedData = analyzePostSchema.parse(req.body);

    // --- Text Analysis ---
    const textHash = generateTextHash(validatedData.text);
    let textAnalysis = null;
    let textReused = false;

    // Check if text analysis exists in Cosmos DB
    const existingTextAnalysis = await findAnalysisByHash(textHash);
    if (existingTextAnalysis && existingTextAnalysis.type === "text") {
      console.log(`♻️ Reusing text analysis for hash: ${textHash}`);
      textAnalysis = existingTextAnalysis.analysis;
      textReused = true;
    } else {
      // Primary analysis: Use Azure OpenAI LLM for scoring (REQUIRED)
      try {
        const llmResult = await analyzeTextWithLLM(validatedData.text);
        console.log("✅ LLM Analysis Result:", JSON.stringify(llmResult, null, 2));
        
        // Use LLM results as the primary source for text analysis
        textAnalysis = {
          riskLevel: llmResult.riskLevel || "medium",
          riskKeywordsFound: llmResult.riskKeywordsFound || [],
          credibilityScore: llmResult.credibilityScore || 50,
          verdict: normalizeVerdict(llmResult.verdict),
          explanation: llmResult.explanation || ""
        };

        // Store new text analysis
        await storeAnalysis({
          hash: textHash,
          type: "text",
          analysis: textAnalysis
        });
      } catch (error) {
        // Azure OpenAI LLM is required for scoring - return error if unavailable
        console.error("❌ Azure OpenAI LLM analysis failed (required):", error.message);
        const llmError = new Error(`Azure OpenAI LLM analysis is required but failed: ${error.message}. Please ensure Azure OpenAI is properly configured.`);
        llmError.statusCode = 503; // Service Unavailable
        return next(llmError);
      }
    }

    // --- Image Analysis ---
    let imageAnalysis = { status: "skipped" };
    let imageReused = false;

    if (validatedData.imageUrl) {
      try {
        // Attempt to download image (never throws - returns result object)
        const downloadResult = await downloadImage(validatedData.imageUrl);

        if (downloadResult.success && downloadResult.buffer) {
          const imageHash = generateImageHash(downloadResult.buffer);
          
          // Check if image analysis exists in Cosmos DB
          const existingImageAnalysis = await findAnalysisByHash(imageHash);
          if (existingImageAnalysis && existingImageAnalysis.type === "image") {
            console.log(`♻️ Reusing image analysis for hash: ${imageHash}`);
            imageAnalysis = existingImageAnalysis.analysis;
            imageReused = true;
          } else {
            // Image downloaded successfully - process it
            try {
              // Privacy First: Metadata analysis only looks at file size/attributes, not EXIF/GPS
              const metadata = analyzeImageMetadata(downloadResult.buffer);
              const tracing = traceImage(downloadResult.buffer);
              const { score: credibilityScore, verdict } = calculateImageCredibility(metadata, tracing);

              imageAnalysis = {
                status: "processed",
                metadata,
                tracing,
                credibilityScore,
                verdict
              };

              // Store new image analysis
              await storeAnalysis({
                hash: imageHash,
                type: "image",
                analysis: imageAnalysis
              });
            } catch (error) {
              // Handle any errors during image processing gracefully
              console.error(`[Image Analysis] Processing error: ${error.message}`);
              imageAnalysis = { status: "skipped" };
            }
          }
        } else {
          // Image download failed - set to "skipped"
          console.warn(`[Image Analysis] Skipped due to download failure: ${downloadResult.error}`);
          imageAnalysis = { status: "skipped" };
        }
      } catch (error) {
        // Extra safety net - should never reach here, but handle just in case
        console.error(`[Image Analysis] Unexpected error: ${error.message}`);
        imageAnalysis = { status: "skipped" };
      }
    }

    // Calculate final score combining text and image analysis
    const finalResult = calculateFinalScore(textAnalysis, imageAnalysis);

    // Return response with analysis results and reuse information
    res.json({
      success: true,
      textAnalysis: {
        ...textAnalysis,
        reused: textReused
      },
      imageAnalysis: {
        ...imageAnalysis,
        reused: imageReused
      },
      finalResult,
      privacyPolicy: "Verified by TrustLens - No raw user content or sensitive metadata persisted."
    });
  } catch (error) {
    // Handle Zod validation errors
    if (error instanceof z.ZodError) {
      const validationError = new Error(error.errors[0].message);
      validationError.statusCode = 400;
      return next(validationError);
    }
    // All other errors go to error handler
    next(error);
  }
});

export default router;
