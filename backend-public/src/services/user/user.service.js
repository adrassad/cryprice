// src/services/user/user.service.js
import { db } from "../../db/index.js";
import {
  setUserToCache,
  getUserCache,
  getUsersPageFromCache,
  setUsersToCache,
} from "../../cache/user.cache.js";

/**
 * Создать пользователя, если его нет
 */
export async function createIfNotExists(user_data) {
  let user = await getUserCache(user_data.id);

  if (!user) {
    user = await db.users.findById(user_data.id);
    if (!user) {
      user = await db.users.create(user_data);
      if (!user) {
        user = await db.users.findById(user_data.id);
      }
    } else {
      user = await db.users.update(user_data.id, {
        username: user_data.username,
        first_name: user_data.first_name,
        last_name: user_data.last_name,
      });
    }
    if (user) await setUserToCache(user_data.id, user);
  } else {
    user = await db.users.update(user_data.id, {
      username: user_data.username,
      first_name: user_data.first_name,
      last_name: user_data.last_name,
    });
    if (!user) {
      user = await db.users.create(user_data);
      if (!user) {
        user = await db.users.findById(user_data.id);
      }
    }
    if (user) await setUserToCache(user_data.id, user);
  }

  return user;
}

export async function getAllUsers() {
  const users = await getUsersPageFromCache();
  // Redis returns [] when down or when the index is empty — treat as cache miss.
  if (!users?.length) {
    return await db.users.findAll();
  }
  return users;
}

export async function getAllUsersDb() {
  const users = await db.users.findAll();
  setUsersToCache(users);
  return users;
}

/**
 * Профиль для бота (публичная сборка без коммерческой подписки).
 */
export async function getUserProfile(telegramId) {
  let user = await getUserCache(telegramId);

  if (!user) {
    user = await db.users.findById(telegramId);
    if (!user) return null;

    await setUserToCache(user.telegram_id, user);
  }

  return {
    telegram_id: user.telegram_id,
    username: user.username,
    threshold_hf: user.threshold_hf,
    first_name: user.first_name,
    last_name: user.last_name,
  };
}

export async function loadUsersToCache() {
  const users = await db.users.findAll();
  for (const user of users) {
    await setUserToCache(user.telegram_id, user);
  }
}

export async function updateUser(user_id, user_data) {
  const user = await db.users.updateUser(user_id, user_data);
  if (user) await setUserToCache(user_id, user);
  return user;
}
