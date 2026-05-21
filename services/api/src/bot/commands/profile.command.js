import { getUserProfile } from "../../services/user/user.service.js";
import { t } from "../locales/index.js";
import { buildProfileText } from "../utils/profile-text.js";

export function profileCommand(bot) {
  bot.command("profile", async (ctx) => {
    try {
      const userId = ctx.from.id;
      const profile = await getUserProfile(userId);

      if (!profile) {
        return ctx.reply(t(ctx.from.language_code, "profile.notFound"));
      }

      const text = buildProfileText(profile, ctx.from.language_code);

      await ctx.reply(text, {
        parse_mode: "HTML",
      });
    } catch (error) {
      console.error("Profile command error:", new Date().toISOString(), error);

      await ctx.reply(
        ctx.from.language_code?.startsWith("ru")
          ? "❌ Не удалось загрузить профиль. Попробуйте позже."
          : "❌ Failed to load profile. Please try again later.",
      );
    }
  });
}
