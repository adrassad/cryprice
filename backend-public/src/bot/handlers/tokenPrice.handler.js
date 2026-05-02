import { createRedisRateLimitGuard } from "../guards/rate-limit.guard.js";
import { getAssetBySymbol } from "../../services/asset/asset.service.js";
import { getAssetPriceUSD } from "../../services/price/price.service.js";
import { t } from "../locales/index.js";

const priceRateLimit = createRedisRateLimitGuard({
  windowSec: 60,
  maxRequests: 10,
  action: "price_lookup",
});

export function tokenPriceHandler(bot) {
  bot.on("text", async (ctx) => {
    const rawText = ctx.message?.text?.trim();
    if (!rawText) return;

    if (rawText.startsWith("/")) return;
    if (ctx.scene?.current) return;
    if (!isTickerQuery(rawText)) return;
    if (!(await priceRateLimit(ctx))) return;

    const parts = rawText.split(/\s+/);
    let symbol = parts[0].toUpperCase();

    const rawAmount = parts[1] ? parts[1].replace(",", ".") : "1";
    const amount = Number(rawAmount);

    if (!Number.isFinite(amount) || amount <= 0) {
      return ctx.reply(
        t(ctx.from.language_code, "token_invalid_amount") ||
          (ctx.from.language_code?.startsWith("ru")
            ? "⚠️ Некорректное количество"
            : "⚠️ Invalid amount"),
      );
    }

    try {
      let netAsset = await getAssetBySymbol(symbol);

      if (netAsset.size === 0 && !symbol.startsWith("W")) {
        symbol = `W${symbol}`;
        netAsset = await getAssetBySymbol(symbol);
      }

      if (netAsset.size === 0) {
        await ctx.reply(
          t(ctx.from.language_code, "token_not_found", { symbol }),
          { parse_mode: "HTML" },
        );
        return;
      }

      const rows = await Promise.all(
        Array.from(netAsset.entries()).map(async ([network, asset]) => {
          const priceUSD = await getAssetPriceUSD(network.id, asset.address);
          const total = priceUSD * amount;

          return {
            networkName: network.name,
            priceUSD,
            total,
          };
        }),
      );

      let message = `💰 <b>${symbol}</b>\n<pre>`;

      for (const row of rows) {
        message += `${row.networkName}\n`;
        message += `${amount} ${symbol} = $${row.total.toFixed(2)}\n`;
        message += `price: $${row.priceUSD.toFixed(2)}\n\n`;
      }

      message += `</pre>`;

      await ctx.reply(message, {
        parse_mode: "HTML",
        disable_web_page_preview: true,
      });
    } catch (err) {
      console.error("Token price fetch error:", new Date().toISOString(), err);

      await ctx.reply(
        t(ctx.from.language_code, "token_price_error") ||
          (ctx.from.language_code?.startsWith("ru")
            ? "⚠️ Ошибка получения цены"
            : "⚠️ Failed to fetch token price"),
      );
    }
  });
}

export function isTickerQuery(text) {
  return /^[A-Za-z]{2,10}(\s+\d+([.,]\d+)?)?$/.test(text.trim());
}
