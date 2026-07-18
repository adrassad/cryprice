import rateLimit from 'express-rate-limit';

const RATE_LIMITED_BODY = {
  error: 'Too many requests, please try again later.'
};

// General API: 60 requests per minute per IP
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: RATE_LIMITED_BODY,
});

/** Stricter bucket for public marketing contact form submissions. */
export const contactFormApiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: RATE_LIMITED_BODY,
});

export default apiLimiter;
