import { ENV } from "../../config/env.js";
import { sendContactFormEmail } from "./contactMail.service.js";
import { verifyTurnstileToken } from "./turnstileVerify.service.js";

const CONTACT_TOPICS = new Set([
  "support",
  "security",
  "privacy",
  "legal",
  "press",
  "other",
]);

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export class ContactFormError extends Error {
  /**
   * @param {string} code
   * @param {string} message
   * @param {number} status
   */
  constructor(code, message, status) {
    super(message);
    this.name = "ContactFormError";
    this.code = code;
    this.status = status;
  }
}

/**
 * @param {unknown} value
 */
function asTrimmedString(value) {
  return typeof value === "string" ? value.trim() : "";
}

/**
 * @param {unknown} body
 */
export function parseContactFormBody(body) {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    throw new ContactFormError(
      "INVALID_BODY",
      "Request body must be a JSON object.",
      400,
    );
  }

  const record = /** @type {Record<string, unknown>} */ (body);
  const name = asTrimmedString(record.name);
  const email = asTrimmedString(record.email);
  const topic = asTrimmedString(record.topic);
  const message = asTrimmedString(record.message);
  const website = asTrimmedString(record.website);
  const turnstileToken = asTrimmedString(record.turnstileToken);

  if (website) {
    throw new ContactFormError(
      "INVALID_BODY",
      "Unable to process this submission.",
      400,
    );
  }

  if (!name || name.length > 120) {
    throw new ContactFormError(
      "INVALID_BODY",
      "Name is required and must be at most 120 characters.",
      400,
    );
  }

  if (!email || email.length > 254 || !EMAIL_PATTERN.test(email)) {
    throw new ContactFormError(
      "INVALID_BODY",
      "A valid email address is required.",
      400,
    );
  }

  if (!CONTACT_TOPICS.has(topic)) {
    throw new ContactFormError("INVALID_BODY", "Topic is invalid.", 400);
  }

  if (!message || message.length < 10 || message.length > 5000) {
    throw new ContactFormError(
      "INVALID_BODY",
      "Message must be between 10 and 5000 characters.",
      400,
    );
  }

  if (!turnstileToken) {
    throw new ContactFormError(
      "INVALID_BODY",
      "Security verification is required.",
      400,
    );
  }

  return { name, email, topic, message, turnstileToken };
}

export function isContactFormConfigured() {
  return Boolean(
    ENV.TURNSTILE_SECRET_KEY?.trim() && ENV.CONTACT_FORM_TO?.trim(),
  );
}

/**
 * @param {{ body: unknown, remoteIp?: string }} params
 */
export async function submitContactForm({ body, remoteIp }) {
  if (!isContactFormConfigured()) {
    throw new ContactFormError(
      "CONTACT_NOT_CONFIGURED",
      "Contact form is not available.",
      503,
    );
  }

  const payload = parseContactFormBody(body);
  const verified = await verifyTurnstileToken({
    token: payload.turnstileToken,
    remoteIp,
  });

  if (!verified) {
    throw new ContactFormError(
      "TURNSTILE_FAILED",
      "Security verification failed. Please try again.",
      400,
    );
  }

  const to = ENV.CONTACT_FORM_TO.trim();
  const from = ENV.CONTACT_FORM_FROM.trim();
  const subject = `[CryPrice Contact:${payload.topic}] ${payload.name}`;
  const text = [
    `Topic: ${payload.topic}`,
    `Name: ${payload.name}`,
    `Email: ${payload.email}`,
    remoteIp ? `IP: ${remoteIp}` : null,
    "",
    payload.message,
  ]
    .filter(Boolean)
    .join("\n");

  await sendContactFormEmail({
    to,
    from,
    replyTo: payload.email,
    subject,
    text,
  });

  return { ok: true };
}
