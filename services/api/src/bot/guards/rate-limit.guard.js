import { incrementRateLimit } from "../../cache/ratelimit.cache.js";
import { t } from "../locales/index.js";

export function createRedisRateLimitGuard({
  windowSec = 60,
  maxRequests = 10,
  action = "default",
} = {}) {
  return async function redisRateLimitGuard(ctx) {
    const userId = ctx.from?.id;
    if (!userId) return true;

    const current = await incrementRateLimit(userId, action, windowSec);

    if (current !== null && current > maxRequests) {
      await ctx.reply(t(ctx.from.language_code, "requests_limit"));
      return false;
    }

    return true;
  };
}
