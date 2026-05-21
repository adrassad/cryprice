import { readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok, strictEqual } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const middlewarePath = join(
  root,
  "src/bot/middlewares/requireLinkedTelegramUser.middleware.js",
);
const bypassPath = join(
  root,
  "src/bot/middlewares/requireLinkedTelegramUser.bypass.js",
);

function readBotFiles(dir, acc = []) {
  for (const entry of readdirSync(dir)) {
    const fullPath = join(dir, entry);
    if (statSync(fullPath).isDirectory()) {
      readBotFiles(fullPath, acc);
    } else if (entry.endsWith(".js")) {
      acc.push(fullPath);
    }
  }
  return acc;
}

test("linked-user middleware file exists and uses lookup-only helpers", () => {
  const src = readFileSync(middlewarePath, "utf8");
  ok(src.includes("getUserByTelegramId"));
  ok(src.includes("findUserByTelegramId"));
  ok(!src.includes("getOrCreateUserByTelegramProfile"));
});

test("bot.js registers linked-user middleware after session and before stage", () => {
  const src = readFileSync(join(root, "src/bot/bot.js"), "utf8");
  ok(src.includes("requireLinkedTelegramUser"));
  ok(src.includes("bot.use(session());"));
  ok(src.includes("bot.use(requireLinkedTelegramUser());"));
  ok(src.includes("bot.use(stage.middleware());"));

  const sessionIdx = src.indexOf("bot.use(session());");
  const middlewareIdx = src.indexOf("bot.use(requireLinkedTelegramUser());");
  const stageIdx = src.indexOf("bot.use(stage.middleware());");

  ok(sessionIdx >= 0 && middlewareIdx > sessionIdx && stageIdx > middlewareIdx);
});

test("no file under src/bot uses getOrCreateUserByTelegramProfile", () => {
  const botDir = join(root, "src/bot");
  for (const filePath of readBotFiles(botDir)) {
    const src = readFileSync(filePath, "utf8");
    ok(
      !src.includes("getOrCreateUserByTelegramProfile"),
      `${filePath} must not use getOrCreateUserByTelegramProfile`,
    );
  }
});

test("start.command.js and addWallet.scene.js remain lookup-only", () => {
  const start = readFileSync(
    join(root, "src/bot/commands/start.command.js"),
    "utf8",
  );
  ok(!start.includes("getOrCreateUserByTelegramProfile"));
  ok(start.includes("getUserByTelegramId"));
  ok(start.includes("findUserByTelegramId"));

  const addWallet = readFileSync(
    join(root, "src/bot/scenes/addWallet.scene.js"),
    "utf8",
  );
  ok(!addWallet.includes("getOrCreateUserByTelegramProfile"));
  ok(addWallet.includes("getUserByTelegramId"));
  ok(addWallet.includes("findUserByTelegramId"));
});

test("bypass helper allows public commands only", async () => {
  const { normalizeBotCommand, shouldBypassLinkedUserCheck } = await import(
    `${bypassPath}?bypass=${Date.now()}`
  );

  strictEqual(normalizeBotCommand("/start"), "/start");
  strictEqual(normalizeBotCommand("/start@CryPriceBot link_abc"), "/start");
  strictEqual(normalizeBotCommand("/help@CryPriceBot"), "/help");

  ok(
    shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "/start" },
    }),
  );
  ok(
    shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "/start link_abc123" },
    }),
  );
  ok(
    shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "/help" },
    }),
  );
  ok(
    shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "/support" },
    }),
  );
  ok(
    !shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "/profile" },
    }),
  );
  ok(
    !shouldBypassLinkedUserCheck({
      from: { id: 100 },
      message: { text: "ETH" },
    }),
  );
});
