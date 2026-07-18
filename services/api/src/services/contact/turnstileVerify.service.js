import { ENV } from "../../config/env.js";

const TURNSTILE_VERIFY_URL =
  "https://challenges.cloudflare.com/turnstile/v0/siteverify";

/**
 * @param {{ token: string, remoteIp?: string }} params
 * @returns {Promise<boolean>}
 */
export async function verifyTurnstileToken({ token, remoteIp }) {
  const secret = ENV.TURNSTILE_SECRET_KEY?.trim();
  if (!secret) {
    return false;
  }

  const body = new URLSearchParams();
  body.set("secret", secret);
  body.set("response", token);
  if (remoteIp) {
    body.set("remoteip", remoteIp);
  }

  const response = await fetch(TURNSTILE_VERIFY_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });

  if (!response.ok) {
    return false;
  }

  const payload = await response.json();
  return Boolean(payload?.success);
}
