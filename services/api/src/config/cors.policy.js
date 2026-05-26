const LOCALHOST_ORIGIN_RE =
  /^https?:\/\/(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/;

/**
 * @param {string | undefined} raw
 * @returns {string[]}
 */
export function parseCorsAllowedOrigins(raw) {
  if (!raw?.trim()) return [];
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

/**
 * @param {string} nodeEnv
 * @param {string[]} configuredOrigins
 * @returns {string[] | null} explicit list, or null for dev/test localhost policy
 */
export function resolveCorsOriginPolicy(nodeEnv, configuredOrigins) {
  if (configuredOrigins.includes("*")) {
    throw new Error(
      'CORS wildcard "*" is not allowed. Set explicit origins in CORS_ALLOWED_ORIGINS.',
    );
  }

  if (configuredOrigins.length > 0) {
    return configuredOrigins;
  }

  if (nodeEnv === "production") {
    throw new Error(
      "CORS_ALLOWED_ORIGINS is required in production. Set comma-separated allowed origins (e.g. https://app.cryprice.dev,https://cryprice.dev).",
    );
  }

  return null;
}

/**
 * @param {string | undefined} origin
 * @returns {boolean}
 */
export function isLocalDevOrigin(origin) {
  if (!origin) return true;
  return LOCALHOST_ORIGIN_RE.test(origin);
}
