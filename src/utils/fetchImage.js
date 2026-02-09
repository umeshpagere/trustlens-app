import axios from "axios";

/**
 * Safely downloads an image from a URL without throwing errors.
 * Returns a result object indicating success or failure.
 * 
 * @param {string} url - The image URL to download
 * @returns {Promise<{success: boolean, buffer?: Buffer, error?: string}>}
 */
export async function downloadImage(url) {
  try {
    const response = await axios.get(url, {
      responseType: "arraybuffer",
      timeout: 5000,
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });

    return {
      success: true,
      buffer: Buffer.from(response.data)
    };
  } catch (error) {
    // Log error for debugging but don't throw
    let errorMessage = "Unknown error";
    
    if (error.code === "ECONNABORTED") {
      errorMessage = "Image download timed out after 5 seconds";
    } else if (error.response) {
      errorMessage = `Failed to download image: HTTP ${error.response.status}`;
    } else if (error.request) {
      errorMessage = "Failed to download image: No response from server";
    } else {
      errorMessage = `Failed to download image: ${error.message}`;
    }

    console.error(`[Image Download Error] ${url}: ${errorMessage}`);

    return {
      success: false,
      error: errorMessage
    };
  }
}

// Keep fetchImage for backward compatibility (deprecated - use downloadImage instead)
export async function fetchImage(imageUrl) {
  const result = await downloadImage(imageUrl);
  if (!result.success) {
    throw new Error(result.error);
  }
  return result.buffer;
}

