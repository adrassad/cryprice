// src/config/env.js
import "dotenv/config";

function parseBoolFlag(value) {
  return value === "true" || value === "1";
}

function parsePort() {
  const raw = process.env.PORT_API ?? process.env.PORT ?? "3000";
  const n = Number(raw);
  return Number.isFinite(n) && n > 0 ? n : 3000;
}

function parseGoogleClientIds() {
  const raw = process.env.GOOGLE_CLIENT_ID ?? "";
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

function parsePositiveInt(raw, fallback) {
  const n = Number(raw);
  return Number.isFinite(n) && n > 0 ? Math.floor(n) : fallback;
}

const NODE_ENV = process.env.NODE_ENV || "development";

export const ENV = {
  NODE_ENV,
  PORT_API: parsePort(),
  DATABASE_URL: process.env.DATABASE_URL,
  BOT_TOKEN: process.env.BOT_TOKEN,
  GEMINI_API_KEY: process.env.GEMINI_API_KEY,
  GEMINI_MODEL: process.env.GEMINI_MODEL || "gemini-2.5-flash",
  GEMINI_FALLBACK_MODEL:
    process.env.GEMINI_FALLBACK_MODEL || "gemini-2.0-flash",

  REDIS_HOST: process.env.REDIS_HOST || "127.0.0.1",
  REDIS_PORT: Number(process.env.REDIS_PORT) || 6379,
  REDIS_DB: Number(process.env.REDIS_DB) || 0,
  REDIS_PASSWORD: process.env.REDIS_PASSWORD || undefined,

  /** Comma-separated OAuth 2.0 client IDs (Web / iOS / Android) for Google Sign-In. */
  GOOGLE_CLIENT_IDS: parseGoogleClientIds(),

  /** HS256 secret for API access JWT (min 32 chars recommended in production). */
  JWT_ACCESS_SECRET: process.env.JWT_ACCESS_SECRET || "",
  JWT_ACCESS_EXPIRES_SEC: parsePositiveInt(
    process.env.JWT_ACCESS_EXPIRES_SEC,
    900,
  ),
  JWT_REFRESH_EXPIRES_SEC: parsePositiveInt(
    process.env.JWT_REFRESH_EXPIRES_SEC,
    604800,
  ),
  JWT_ISSUER: process.env.JWT_ISSUER || "cryprice-api",
  JWT_AUDIENCE: process.env.JWT_AUDIENCE || "cryprice-clients",
};

/**
 * Redis flush on startup: only when explicitly enabled and not in production.
 */
export function shouldFlushRedisOnStart() {
  if (!parseBoolFlag(process.env.FLUSH_REDIS_ON_START ?? "")) {
    return false;
  }
  if (NODE_ENV === "production") {
    console.error(
      "[config] FLUSH_REDIS_ON_START is set but ignored when NODE_ENV=production (safety).",
    );
    return false;
  }
  return true;
}

function validateStartupEnv() {
  const missing = [];
  if (!ENV.DATABASE_URL) missing.push("DATABASE_URL");
  if (!ENV.BOT_TOKEN) missing.push("BOT_TOKEN");
  if (missing.length) {
    throw new Error(
      `Missing required environment variables: ${missing.join(", ")}. Set them in the environment or .env file.`,
    );
  }
}

validateStartupEnv();
