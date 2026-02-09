export default function errorHandler(err, req, res, next) {
    console.error(err);
  
    // Ensure message is always a string and properly escaped
    const message = err.message || "Internal Server Error";
    const safeMessage = typeof message === "string" ? message : String(message);
  
    res.status(err.statusCode || 500).json({
      success: false,
      message: safeMessage
    });
  }
  