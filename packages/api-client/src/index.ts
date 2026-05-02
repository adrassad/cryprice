/**
 * Публичный HTTP/SDK-клиент к Cryprice API.
 * Реализацию методов добавьте по спецификации в docs/public-api.md.
 */

import { CRYPRICE_PKG } from "@cryprice/shared";

export type CrypriceClientOptions = {
  baseUrl: string;
  /** Опционально: API key, если включена авторизация */
  apiKey?: string;
};

export function createCrypriceClient(_options: CrypriceClientOptions) {
  // TODO: реализовать fetch-обёртки и типы ответов
  return { _pkg: CRYPRICE_PKG };
}
