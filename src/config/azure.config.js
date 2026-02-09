import { OpenAIClient, AzureKeyCredential } from "@azure/openai";
import { env } from "./azure.env.js";

/**
 * Azure OpenAI client configuration
 * Uses @azure/openai v1.x SDK
 * Lazy initialization - only creates client when needed (not on startup)
 */
let _azureOpenAIClient = null;

export function getAzureOpenAIClient() {
  if (!_azureOpenAIClient) {
    if (!env.AZURE_OPENAI_ENDPOINT || !env.AZURE_OPENAI_API_KEY) {
      console.error("❌ Azure OpenAI configuration missing!");
      console.error("AZURE_OPENAI_ENDPOINT:", env.AZURE_OPENAI_ENDPOINT ? "✅" : "❌");
      console.error("AZURE_OPENAI_API_KEY:", env.AZURE_OPENAI_API_KEY ? "✅" : "❌");
      throw new Error("Azure OpenAI configuration missing. Check your .env file.");
    }
    
    _azureOpenAIClient = new OpenAIClient(
      env.AZURE_OPENAI_ENDPOINT,
      new AzureKeyCredential(env.AZURE_OPENAI_API_KEY),
      { apiVersion: env.AZURE_OPENAI_API_VERSION }
    );
  }
  return _azureOpenAIClient;
}
