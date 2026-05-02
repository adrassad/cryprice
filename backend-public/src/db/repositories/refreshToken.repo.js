import { createHash } from "node:crypto";

export function hashRefreshToken(rawToken) {
  return createHash("sha256").update(rawToken, "utf8").digest("hex");
}

export class RefreshTokenRepository {
  constructor(db) {
    this.db = db;
  }

  async insert(userTelegramId, rawToken, expiresAt) {
    const tokenHash = hashRefreshToken(rawToken);
    const { rows } = await this.db.query(
      `
      INSERT INTO refresh_tokens (user_telegram_id, user_id, token_hash, expires_at)
      SELECT u.telegram_id, u.id, $2, $3
      FROM users u
      WHERE u.telegram_id = $1
      RETURNING id, user_telegram_id, user_id, expires_at, created_at
      `,
      [userTelegramId, tokenHash, expiresAt],
    );
    return rows[0] ?? null;
  }

  async findValidByRawToken(rawToken) {
    const tokenHash = hashRefreshToken(rawToken);
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM refresh_tokens
      WHERE token_hash = $1
        AND revoked_at IS NULL
        AND expires_at > NOW()
      LIMIT 1
      `,
      [tokenHash],
    );
    return rows[0] ?? null;
  }

  async revokeByRawToken(rawToken) {
    const tokenHash = hashRefreshToken(rawToken);
    const { rows } = await this.db.query(
      `
      UPDATE refresh_tokens
      SET revoked_at = NOW()
      WHERE token_hash = $1 AND revoked_at IS NULL
      RETURNING *
      `,
      [tokenHash],
    );
    return rows[0] ?? null;
  }

  async revokeAllForUser(userTelegramId) {
    await this.db.query(
      `
      UPDATE refresh_tokens
      SET revoked_at = NOW()
      WHERE user_telegram_id = $1 AND revoked_at IS NULL
      `,
      [userTelegramId],
    );
  }

  /**
   * Atomically revoke one valid refresh token and insert the next (rotation).
   * On any failure the transaction rolls back — the old token stays usable.
   * @returns {Promise<{ userId: string | null, userTelegramId: string } | null>}
   */
  async rotateRefreshToken(rawOld, rawNew, expiresAt) {
    const oldHash = hashRefreshToken(rawOld);
    const newHash = hashRefreshToken(rawNew);
    const client = await this.db.pool.connect();
    try {
      await client.query("BEGIN");
      const upd = await client.query(
        `
        UPDATE refresh_tokens
        SET revoked_at = NOW()
        WHERE token_hash = $1
          AND revoked_at IS NULL
          AND expires_at > NOW()
        RETURNING user_telegram_id, user_id
        `,
        [oldHash],
      );
      if (!upd.rows.length) {
        await client.query("ROLLBACK");
        return null;
      }
      const userTelegramId = upd.rows[0].user_telegram_id;
      const userId = upd.rows[0].user_id;
      await client.query(
        `
        INSERT INTO refresh_tokens (user_telegram_id, user_id, token_hash, expires_at)
        SELECT $1, COALESCE($2::bigint, u.id), $3, $4
        FROM users u
        WHERE u.telegram_id = $1
        `,
        [userTelegramId, userId, newHash, expiresAt],
      );
      await client.query("COMMIT");
      return {
        userId: userId != null ? String(userId) : null,
        userTelegramId: String(userTelegramId),
      };
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }
}
