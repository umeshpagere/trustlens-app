# TrustLens Backend

TrustLens is a misinformation risk assessment API that analyzes text and images to determine their credibility and reliability. The backend combines rule-based analysis with Azure OpenAI LLM capabilities to provide comprehensive content verification.

## Features

- **Text Analysis**: Rule-based and AI-powered analysis of text content for misinformation risk
- **Image Analysis**: Metadata extraction, reverse image tracing, and credibility scoring
- **Hybrid Scoring**: Combines text and image analysis for comprehensive risk assessment
- **Azure OpenAI Integration**: Optional LLM-powered explanations and enhanced analysis
- **Graceful Error Handling**: Continues analysis even if optional services fail

## Prerequisites

- **Node.js**: LTS version (v18 or v20 recommended)
- **npm**: Package manager (comes with Node.js)
- **Azure OpenAI Account**: For LLM-powered analysis (optional - works without it)

## Installation

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd trustlens-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   ```

4. **Configure your `.env` file**:
   ```env
   # Azure OpenAI Configuration (optional - API works without it)
   AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
   AZURE_OPENAI_API_KEY=your-api-key
   AZURE_OPENAI_DEPLOYMENT=your-deployment-name
   AZURE_OPENAI_API_VERSION=2024-02-15-preview

   # Server Configuration
   PORT=5000
   ```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:5000` (or the port specified in your `.env` file).

## API Documentation

### Base URL
```
http://localhost:5000
```

### Endpoints

#### 1. Health Check
**GET** `/`

Returns the API status.

**Response:**
```json
{
  "status": "TrustLens API running"
}
```

#### 2. API Information
**GET** `/api/analyze`

Returns API documentation and usage information.

**Response:**
```json
{
  "success": true,
  "message": "TrustLens Analyze API",
  "endpoint": "/api/analyze",
  "method": "POST",
  "description": "Analyze text and images for misinformation risk assessment",
  "requestBody": {
    "text": {
      "type": "string",
      "required": true,
      "minLength": 5,
      "description": "Text content to analyze"
    },
    "imageUrl": {
      "type": "string",
      "required": false,
      "format": "url",
      "description": "Optional image URL to analyze"
    }
  },
  "example": {
    "text": "This is a sample text to analyze for misinformation",
    "imageUrl": "https://example.com/image.jpg"
  }
}
```

#### 3. Analyze Content
**POST** `/api/analyze`

Analyzes text and optionally an image for misinformation risk.

**Request Body:**
```json
{
  "text": "Your text content to analyze (minimum 5 characters)",
  "imageUrl": "https://example.com/image.jpg" // optional
}
```

**Response:**
```json
{
  "success": true,
  "textAnalysis": {
    "riskLevel": "low" | "medium" | "high",
    "riskKeywordsFound": ["keyword1", "keyword2"],
    "credibilityScore": 100,
    "verdict": "Reliable" | "Questionable" | "High Risk",
    "explanation": "AI-generated explanation (if LLM available)"
  },
  "imageAnalysis": {
    "status": "processed" | "skipped",
    "metadata": { /* image metadata */ },
    "tracing": { /* reverse image search results */ },
    "credibilityScore": 85,
    "verdict": "Reliable" | "Questionable" | "High Risk"
  },
  "finalResult": {
    "finalScore": 95,
    "finalVerdict": "Reliable" | "Questionable" | "High Risk"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message description"
}
```

## Usage Examples

### cURL Examples

**Text-only analysis:**
```bash
curl -X POST http://localhost:5000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "text": "This is a sample news article to verify for misinformation"
  }'
```

**Text with image analysis:**
```bash
curl -X POST http://localhost:5000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Breaking news: Check this image",
    "imageUrl": "https://example.com/news-image.jpg"
  }'
```

### JavaScript/Node.js Example

```javascript
const response = await fetch('http://localhost:5000/api/analyze', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: 'Your text content here',
    imageUrl: 'https://example.com/image.jpg' // optional
  })
});

const result = await response.json();
console.log(result);
```

### Python Example

```python
import requests

url = "http://localhost:5000/api/analyze"
payload = {
    "text": "Your text content here",
    "imageUrl": "https://example.com/image.jpg"  # optional
}

response = requests.post(url, json=payload)
result = response.json()
print(result)
```

## Analysis Features

### Text Analysis
- **Rule-based Analysis**: Keyword detection, pattern matching, and risk scoring
- **LLM Analysis** (optional): AI-powered explanation and enhanced risk assessment using Azure OpenAI
- **Verdict Categories**: Reliable, Questionable, High Risk

### Image Analysis
- **Metadata Extraction**: EXIF data analysis, creation date, camera information
- **Reverse Image Tracing**: Attempts to find original source of images
- **Credibility Scoring**: Based on metadata integrity and source verification

### Final Scoring
- Combines text and image analysis scores
- Weighted calculation for comprehensive risk assessment
- Final verdict: Reliable, Questionable, or High Risk

## Project Structure

```
trustlens-backend/
├── src/
│   ├── app.js                 # Express app configuration
│   ├── config/
│   │   ├── azure.config.js    # Azure OpenAI client setup
│   │   └── azure.env.js       # Environment variable loader
│   ├── middleware/
│   │   └── errorHandler.js    # Global error handler
│   ├── models/
│   │   ├── post.schema.js     # Request validation schemas
│   │   └── response.schema.js # Response schemas
│   ├── routes/
│   │   └── analyze.route.js   # Main API route
│   ├── services/
│   │   ├── textAnalysis.service.js    # Text analysis logic
│   │   ├── llmAnalysis.service.js     # Azure OpenAI integration
│   │   ├── imageMetadata.service.js   # Image metadata extraction
│   │   ├── imageTracing.service.js    # Reverse image search
│   │   ├── imageScoring.service.js    # Image credibility scoring
│   │   └── scoring.service.js         # Final score calculation
│   └── utils/
│       ├── constants.js       # Application constants
│       ├── fetchImage.js      # Image download utility
│       └── logger.js          # Logging utilities
├── server.js                  # Server entry point
├── package.json               # Dependencies and scripts
├── .env.example              # Environment variables template
└── README.md                 # This file
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `AZURE_OPENAI_ENDPOINT` | No | Azure OpenAI endpoint URL |
| `AZURE_OPENAI_API_KEY` | No | Azure OpenAI API key |
| `AZURE_OPENAI_DEPLOYMENT` | No | Azure OpenAI deployment name |
| `AZURE_OPENAI_API_VERSION` | No | API version (default: 2024-02-15-preview) |
| `PORT` | No | Server port (default: 5000) |

**Note**: The API works without Azure OpenAI credentials. LLM analysis will be skipped, but rule-based text analysis and image analysis will still function.

## Error Handling

The API includes comprehensive error handling:

- **400 Bad Request**: Invalid request body or validation errors
- **404 Not Found**: Route not found
- **500 Internal Server Error**: Server-side errors

All errors return JSON responses in the format:
```json
{
  "success": false,
  "message": "Error description"
}
```

## Development

### Scripts

- `npm run dev`: Start development server with nodemon (auto-reload)
- `npm start`: Start production server

### Code Style

- ES6+ JavaScript with ES modules
- Express.js for routing
- Zod for request validation
- Azure OpenAI SDK for LLM integration

## Security Notes

- Never commit `.env` file to version control
- Keep Azure OpenAI API keys secure
- The `.env` file is already in `.gitignore`
- All API responses are JSON (no HTML error pages)

## Troubleshooting

### Server won't start
- Check if port 5000 is already in use
- Verify Node.js version: `node --version`
- Ensure all dependencies are installed: `npm install`

### Azure OpenAI errors
- Verify your `.env` file has correct credentials
- Check Azure OpenAI endpoint and deployment name
- API will continue working without Azure OpenAI (LLM features disabled)

### Image analysis fails
- Verify image URL is accessible
- Check network connectivity
- Image analysis gracefully fails and continues with text-only analysis

## License

[Add your license information here]

## Support

For issues and questions, please [add your support contact information].
