// src/bot/utils/profile-text.js
import { t } from "../locales/index.js";

export function buildProfileText(profile, languageCode) {
  const { telegram_id, username, threshold_hf, first_name, last_name } =
    profile;

  const fullName =
    [first_name, last_name].filter(Boolean).join(" ") ||
    t(languageCode, "common.notSpecified");

  const userNameText = username
    ? `@${username}`
    : t(languageCode, "common.notSpecified");

  const lines = [
    t(languageCode, "profile.title"),
    "",
    t(languageCode, "profile.telegramId", {
      telegramId: telegram_id,
    }),
    t(languageCode, "profile.name", { name: fullName }),
    t(languageCode, "profile.username", {
      username: userNameText,
    }),
    "",
    t(languageCode, "profile.settingsTitle"),
    t(languageCode, "profile.threshold", {
      value: threshold_hf ?? "—",
    }),
  ];

  return lines.join("\n");
}
