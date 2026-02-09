import { getAzureOpenAIClient } from "../config/azure.config.js";
import { env } from "../config/azure.env.js";

/**
 * Analyzes text using Azure OpenAI LLM for misinformation risk assessment
 * @param {string} text - The text to analyze
 * @returns {Promise<Object>} Analysis result with riskLevel, credibilityScore, verdict, riskKeywordsFound, and explanation
 */
export async function analyzeTextWithLLM(text) {
  if (!text || typeof text !== "string" || text.trim().length === 0) {
    throw new Error("Text input is required");
  }

  try {
    // @azure/openai v1.x uses getChatCompletions method
    const azureOpenAIClient = getAzureOpenAIClient();
    const response = await azureOpenAIClient.getChatCompletions(
      env.AZURE_OPENAI_DEPLOYMENT,
      [
        {
          role: "system",
          content: `You are an expert AI fact-checker that analyzes text for misinformation, fake news, and credibility risks. 
Your analysis should consider:
- Sensational or clickbait language
- Unverified claims or lack of credible sources
- Emotional manipulation tactics
- Conspiracy theories or false narratives
- Patterns typical of misinformation campaigns
- Factual accuracy indicators

Respond ONLY in valid JSON format. No markdown, no code blocks, no extra text.`
        },
        {
          role: "user",
          content: `Analyze this text for misinformation risk and return JSON only in this exact format:
{
  "riskLevel": "low" | "medium" | "high",
  "credibilityScore": number (0-100, where 0 is completely unreliable and 100 is highly credible),
  "verdict": "Reliable" | "Questionable" | "High Risk",
  "riskKeywordsFound": string[],
  "explanation": string (detailed explanation of why this verdict was given)
}

Scoring guidelines:
- 75-100: Reliable - Well-sourced, factual, credible content
- 40-74: Questionable - Some red flags, unverified claims, or suspicious patterns
- 0-39: High Risk - Strong indicators of misinformation, fake news, or manipulation

Text to analyze: ${text}`
        }
      ],
      {
        temperature: 0.2,
        maxTokens: 500,
        responseFormat: { type: "json_object" }
      }
    );

    const content = response.choices[0]?.message?.content;
    
    if (!content) {
      throw new Error("No response content from Azure OpenAI");
    }

    // Parse JSON response, handling potential markdown code blocks
    let parsedContent = content.trim();
    
    // Remove markdown code blocks if present
    if (parsedContent.startsWith("```json")) {
      parsedContent = parsedContent.replace(/^```json\s*/, "").replace(/\s*```$/, "");
    } else if (parsedContent.startsWith("```")) {
      parsedContent = parsedContent.replace(/^```\s*/, "").replace(/\s*```$/, "");
    }

    const result = JSON.parse(parsedContent);

    // Validate required fields
    if (!result.riskLevel || !result.credibilityScore || !result.verdict || !result.explanation) {
      throw new Error("Invalid response format from Azure OpenAI");
    }

    // Ensure riskKeywordsFound is an array
    if (!Array.isArray(result.riskKeywordsFound)) {
      result.riskKeywordsFound = [];
    }

    return result;
  } catch (error) {
    console.error("Azure OpenAI text analysis failed:", error.message);
    if (error instanceof SyntaxError) {
      throw new Error(`Failed to parse LLM response: ${error.message}`);
    }
    throw new Error(`LLM text analysis failed: ${error.message}`);
  }
}
