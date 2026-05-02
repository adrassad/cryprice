/*
 * Извлекает уникальные адреса из Map<address, data[]>
 *
 * @param {Map<string, any[]>} walletsMap
 * @returns {Set<string>}
 */
export function collectUsersWallets(walletsArray) {
  const result = new Map();

  if (!Array.isArray(walletsArray) || walletsArray.length === 0) {
    return result;
  }

  for (const wallet of walletsArray) {
    const { id, user_id, address, label, created_at } = wallet;

    if (!user_id || !address) continue;

    // если у пользователя ещё нет Map — создаём
    if (!result.has(user_id)) {
      result.set(user_id, new Map());
    }

    const userWallets = result.get(user_id);

    userWallets.set(address, {
      id,
      user_id,
      address,
      label,
      created_at,
    });
  }
  return result;
}

/*
 * Извлекает уникальные адреса из структуры:
 * Map<userId, Map<address, Object>>
 *
 * @param {Map<string, Map<string, any>>} usersMap
 * @param {'set'|'array'|'map'} format
 * @returns {Set<string>|string[]|Map<string, true>}
 */
export function extractUniqueAddresses(usersMap, format = "set") {
  if (!(usersMap instanceof Map)) {
    throw new TypeError("usersMap must be a Map");
  }

  const addressSet = new Set();

  for (const walletsMap of usersMap.values()) {
    if (!(walletsMap instanceof Map)) continue;

    for (const address of walletsMap.keys()) {
      addressSet.add(address);
    }
  }

  switch (format) {
    case "array":
      return [...addressSet];

    case "map": {
      const result = new Map();
      for (const addr of addressSet) {
        result.set(addr, true);
      }
      return result;
    }

    case "set":
    default:
      return addressSet;
  }
}
