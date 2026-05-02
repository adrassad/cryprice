import { HttpError } from "../errors/httpError.js";
import { ENV } from "../../config/env.js";

export function errorHandler(err, req, res, next) {
  if (res.headersSent) {
    next(err);
    return;
  }

  if (err instanceof HttpError) {
    res.status(err.status).json({
      error: {
        code: err.code,
        message: err.message,
      },
    });
    return;
  }

  const name = err?.name;
  if (name === "JsonWebTokenError" || name === "TokenExpiredError") {
    res.status(401).json({
      error: {
        code: "INVALID_TOKEN",
        message: "Invalid or expired access token.",
      },
    });
    return;
  }

  console.error("[api] unhandled error:", err);
  const message =
    ENV.NODE_ENV === "production"
      ? "Internal server error."
      : err?.message || "Internal server error.";
  res.status(500).json({
    error: {
      code: "INTERNAL_ERROR",
      message,
    },
  });
}
