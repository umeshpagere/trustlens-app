import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import analyzeRoutes from "./routes/analyze.route.js";
import errorHandler from "./middleware/errorHandler.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.use(cors());
app.use(express.json());

// Handle JSON parsing errors
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      message: "Invalid JSON in request body"
    });
  }
  next(err);
});

// Serve static files from public directory
app.use(express.static(path.join(__dirname, "../public")));

// API health check endpoint
app.get("/api/health", (req, res) => {
  res.json({ status: "TrustLens API running" });
});

app.use("/api/analyze", analyzeRoutes);

// 404 handler - must be before errorHandler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.path} not found`
  });
});

app.use(errorHandler);

export default app;
