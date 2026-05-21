import { redis } from "../redis/redis.client.js";

function rateLimitKey(userId, action = "default") {
  return `rate_limit:${action}:${userId}`;
}

export async function incrementRateLimit(userId, action, windowSec) {
  const key = rateLimitKey(userId, action);

  try {
    const current = await redis.incr(key);

    if (current === 1) {
      await redis.expire(key, windowSec);
    }

    return current;
  } catch (error) {
    console.warn("⚠️ Redis rate limit failed:", error.message);
    return null;
  }
}
