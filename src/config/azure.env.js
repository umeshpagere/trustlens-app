/**
 * Azure OpenAI environment configuration
 * Uses a Proxy to ensure we always get the latest values from process.env
 * This prevents issues with ESM module loading order where modules might be 
 * evaluated before dotenv.config() has finished.
 */
export const env = new Proxy({}, {
  get: (target, prop) => {
    switch (prop) {
      case 'AZURE_OPENAI_ENDPOINT':
        return process.env.AZURE_OPENAI_ENDPOINT;
      case 'AZURE_OPENAI_API_KEY':
        return process.env.AZURE_OPENAI_API_KEY;
      case 'AZURE_OPENAI_DEPLOYMENT':
        return process.env.AZURE_OPENAI_DEPLOYMENT;
      case 'AZURE_OPENAI_API_VERSION':
        return process.env.AZURE_OPENAI_API_VERSION || "2024-08-01-preview";
      default:
        return process.env[prop];
    }
  }
});
