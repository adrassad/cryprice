import { strictEqual, ok, throws } from "node:assert";
import { test } from "node:test";
import {
  ContactFormError,
  parseContactFormBody,
} from "../../src/services/contact/contactForm.service.js";

test("parseContactFormBody accepts valid payload", () => {
  const parsed = parseContactFormBody({
    name: "Alex Researcher",
    email: "alex@example.com",
    topic: "security",
    message: "Reporting a read-only API issue with details.",
    turnstileToken: "token-123",
    website: "",
  });

  strictEqual(parsed.name, "Alex Researcher");
  strictEqual(parsed.email, "alex@example.com");
  strictEqual(parsed.topic, "security");
});

test("parseContactFormBody rejects honeypot submissions", () => {
  throws(
    () =>
      parseContactFormBody({
        name: "Bot",
        email: "bot@example.com",
        topic: "support",
        message: "This is a spam message attempt.",
        turnstileToken: "token-123",
        website: "https://spam.example",
      }),
    (error) => error instanceof ContactFormError && error.code === "INVALID_BODY",
  );
});

test("parseContactFormBody rejects short messages", () => {
  throws(
    () =>
      parseContactFormBody({
        name: "Alex",
        email: "alex@example.com",
        topic: "support",
        message: "short",
        turnstileToken: "token-123",
      }),
    (error) => error instanceof ContactFormError && error.code === "INVALID_BODY",
  );
});

test("parseContactFormBody rejects invalid topic", () => {
  throws(
    () =>
      parseContactFormBody({
        name: "Alex",
        email: "alex@example.com",
        topic: "wallet-connect",
        message: "This topic should not be accepted by the API.",
        turnstileToken: "token-123",
      }),
    (error) => error instanceof ContactFormError && error.code === "INVALID_BODY",
  );
});

test("server.js registers POST /public/contact", async () => {
  const { readFileSync } = await import("node:fs");
  const { dirname, join } = await import("node:path");
  const { fileURLToPath } = await import("node:url");
  const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
  const src = readFileSync(join(root, "src/api/server.js"), "utf8");
  ok(
    src.includes(
      'app.use("/public/contact", contactFormApiLimiter, publicContactRoute)',
    ),
  );
  ok(src.includes("publicContactRoute"));
  ok(src.includes("contactFormApiLimiter"));
});
