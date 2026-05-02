import { redis } from "../redis/redis.client.js";

const TTL = 60 * 120;
const USERS_INDEX_KEY = "users:index";

function usersKey(userId) {
  return `users:${userId}`;
}

export async function setUserToCache(userId, user) {
  if (!redis || redis.status === "end") return;

  try {
    const key = usersKey(userId);
    const payload = JSON.stringify(user);

    await redis
      .multi()
      .set(key, payload, "EX", TTL)
      .sadd(USERS_INDEX_KEY, String(userId))
      .exec();
  } catch (err) {
    console.warn("⚠️ Redis setUserToCache failed:", err.message);
  }
}

export async function setUsersToCache(users) {
  if (
    !redis ||
    redis.status === "end" ||
    !Array.isArray(users) ||
    users.length === 0
  ) {
    return;
  }

  try {
    const multi = redis.multi();

    for (const user of users) {
      const id = user?.telegram_id;
      if (id == null) continue;

      multi.set(usersKey(id), JSON.stringify(user), "EX", TTL);
      multi.sadd(USERS_INDEX_KEY, String(id));
    }

    await multi.exec();
  } catch (err) {
    console.warn("⚠️ Redis setUsersToCache failed:", err.message);
  }
}

export async function getUserCache(userId) {
  if (!redis || redis.status === "end") return null;

  try {
    const userJson = await redis.get(usersKey(userId));
    return userJson ? JSON.parse(userJson) : null;
  } catch (err) {
    console.warn("⚠️ Redis getUserCache failed:", err.message);
    return null;
  }
}

export async function getUsersPageFromCache(offset = 0, limit = 10000) {
  if (!redis || redis.status === "end") return [];

  try {
    const userIds = await redis.smembers(USERS_INDEX_KEY);
    const pageIds = userIds.slice(offset, offset + limit);

    if (!pageIds.length) {
      return [];
    }

    const keys = pageIds.map((userId) => usersKey(userId));
    const usersJson = await redis.mget(keys);

    return usersJson
      .filter(Boolean)
      .map((item) => {
        try {
          return JSON.parse(item);
        } catch {
          return null;
        }
      })
      .filter(Boolean);
  } catch (err) {
    console.warn("⚠️ Redis getUsersPageFromCache failed:", err.message);
    return [];
  }
}
