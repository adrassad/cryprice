import rateLimit from "express-rate-limit";

/** Stricter limit for auth endpoints (brute-force / token stuffing). */
const authLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: {
      code: "RATE_LIMIT",
      message: "Too many authentication attempts. Try again later.",
    },
  },
});

export default authLimiter;
