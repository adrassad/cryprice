import Redis from "ioredis";
import { ENV, shouldFlushRedisOnStart } from "../config/env.js";

const REDIS_DB = ENV.REDIS_DB;

export const redis = new Redis({
  host: ENV.REDIS_HOST,
  port: ENV.REDIS_PORT,
  db: REDIS_DB,
  password: ENV.REDIS_PASSWORD,
  lazyConnect: false, // сразу подключаемся
  maxRetriesPerRequest: 3,
  enableOfflineQueue: true,
  keepAlive: 60000,
  retryStrategy(times) {
    return Math.min(times * 600, 2000);
  },
  reconnectOnError(err) {
    return err.message.includes("READONLY");
  },
});

redis.on("connect", () =>
  console.log("🟢 Redis connected", new Date().toISOString()),
);
redis.on("ready", () =>
  console.log("✅ Redis ready", new Date().toISOString(), "DB:", REDIS_DB),
);
redis.on("error", (err) =>
  console.error("🔴 Redis error:", new Date().toISOString(), err.message),
);
redis.on("close", () => console.warn("⚠️ Redis connection closed"));
redis.on("reconnecting", () =>
  console.log("🔄 Redis reconnecting...", new Date().toISOString()),
);

export async function connectRedis() {
  if (redis.status === "ready") return;
  try {
    await redis.connect();

    if (shouldFlushRedisOnStart()) {
      const before = await redis.dbsize();
      console.log(
        `🧹 Flushing Redis DB ${REDIS_DB} (keys before flush: ${before})`,
      );
      await redis.flushdb();
      const after = await redis.dbsize();
      console.log(`✅ Redis cache cleared (keys after flush: ${after})`);
    }
  } catch (err) {
    console.error(
      "⚠️ Redis connect failed:",
      new Date().toISOString(),
      err.message,
    );
  }
}
