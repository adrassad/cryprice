//src/bot/locales/index.js
import ru from "./ru.js";
import en from "./en.js";

const dictionaries = { ru, en };

function getValueByPath(obj, path) {
  return path.split(".").reduce((acc, part) => acc?.[part], obj);
}

function interpolate(template, params = {}) {
  return template.replace(/\{(\w+)\}/g, (_, key) => {
    return params[key] ?? `{${key}}`;
  });
}

export function getLocale(languageCode) {
  return languageCode?.startsWith("ru") ? "ru" : "en";
}

export function t(languageCode, key, params = {}) {
  const locale = getLocale(languageCode);
  const dict = dictionaries[locale] || dictionaries.en;

  const template =
    getValueByPath(dict, key) ?? getValueByPath(dictionaries.en, key) ?? key;

  return interpolate(template, params);
}
