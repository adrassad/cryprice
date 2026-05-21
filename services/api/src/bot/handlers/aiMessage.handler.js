import { GeminiService } from "../../services/ai/gemini.service.js";
import { scheduleRetry } from "../../services/ai/retryQueue.js";

const geminiService = new GeminiService();

function scheduleAiRetry({ ctx, userPrompt, retrySeconds }) {
  scheduleRetry({
    delayMs: retrySeconds * 1000,
    task: async () => {
      try {
        const reply = await geminiService.generateReply({
          userText: userPrompt,
          profile: {
            telegramId: String(ctx.from.id),
          },
        });

        await ctx.telegram.sendMessage(ctx.chat.id, reply);
      } catch (retryError) {
        if (retryError.message === "AI_QUOTA_EXHAUSTED") {
          const nextRetrySeconds = retryError.retrySeconds || 30;

          await ctx.telegram.sendMessage(
            ctx.chat.id,
            `⏳ Лимит ещё не восстановился. Попробую снова через ${nextRetrySeconds} сек...`,
          );

          scheduleAiRetry({
            ctx,
            userPrompt,
            retrySeconds: nextRetrySeconds,
          });
          return;
        }

        console.error("Retry failed:", retryError);

        await ctx.telegram.sendMessage(
          ctx.chat.id,
          "❌ Не удалось получить ответ от AI.",
        );
      }
    },
  });
}

export function aiMessageHandler(bot) {
  bot.on("text", async (ctx, next) => {
    const text = ctx.message?.text;

    if (!text || text.startsWith("/")) {
      return next();
    }

    const match = text.match(/^ai:\s*(.+)$/i);
    if (!match) {
      return next();
    }

    const userPrompt = match[1].trim();

    if (!userPrompt) {
      await ctx.reply("После ai: напиши вопрос.");
      return;
    }

    try {
      await ctx.sendChatAction("typing");

      const reply = await geminiService.generateReply({
        userText: userPrompt,
        profile: {
          telegramId: String(ctx.from.id),
        },
      });

      await ctx.reply(reply);
    } catch (error) {
      if (error.message === "AI_QUOTA_EXHAUSTED") {
        const retrySeconds = error.retrySeconds || 30;

        await ctx.reply(
          `⏳ Лимит AI достигнут. Попробую снова через ${retrySeconds} сек...`,
        );

        scheduleAiRetry({
          ctx,
          userPrompt,
          retrySeconds,
        });

        return;
      }

      console.error("AI handler error:", error);
      await ctx.reply("Ошибка AI.");
    }
  });
}
