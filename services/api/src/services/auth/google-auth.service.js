import { OAuth2Client } from "google-auth-library";
import { ENV } from "../../config/env.js";
import { HttpError } from "../../api/errors/httpError.js";

const client = new OAuth2Client();

/**
 * Verify Google Sign-In ID token (JWT credential from client).
 * @param {string} idToken
 * @returns {Promise<{ sub: string, email: string, email_verified: boolean, name: string | null, picture: string | null, given_name: string | null, family_name: string | null }>}
 */
export async function verifyGoogleIdToken(idToken) {
  if (!ENV.GOOGLE_CLIENT_IDS.length || !ENV.JWT_ACCESS_SECRET) {
    throw new HttpError(
      503,
      "AUTH_NOT_CONFIGURED",
      "Authentication is not configured on this server.",
    );
  }
  if (
    ENV.NODE_ENV === "production" &&
    ENV.JWT_ACCESS_SECRET.length < 32
  ) {
    throw new HttpError(
      503,
      "AUTH_NOT_CONFIGURED",
      "JWT_ACCESS_SECRET must be at least 32 characters in production.",
    );
  }

  let ticket;
  try {
    ticket = await client.verifyIdToken({
      idToken,
      audience: ENV.GOOGLE_CLIENT_IDS,
    });
  } catch {
    throw new HttpError(401, "GOOGLE_TOKEN_INVALID", "Invalid Google token.");
  }

  const payload = ticket.getPayload();
  if (!payload?.sub) {
    throw new HttpError(401, "GOOGLE_TOKEN_INVALID", "Invalid Google token.");
  }

  return {
    sub: payload.sub,
    email: payload.email ?? "",
    email_verified: Boolean(payload.email_verified),
    name: payload.name ?? null,
    picture: payload.picture ?? null,
    given_name: payload.given_name ?? null,
    family_name: payload.family_name ?? null,
  };
}
