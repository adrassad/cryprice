import { createHash } from "node:crypto";

function hashToken(rawToken) {
  return createHash("sha256").update(rawToken, "utf8").digest("hex");
}

export class AccountLinkTokenRepository {
  constructor(db) {
    this.db = db;
  }

  async create({ rawToken, userId, provider, expiresAt }) {
    const tokenHash = hashToken(rawToken);
    const { rows } = await this.db.query(
      `
      INSERT INTO account_link_tokens (token_hash, user_id, provider, expires_at)
      VALUES ($1, $2, $3, $4)
      RETURNING *
      `,
      [tokenHash, userId, provider, expiresAt],
    );
    return rows[0] ?? null;
  }

  async findValidByRawToken(rawToken, provider) {
    const tokenHash = hashToken(rawToken);
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM account_link_tokens
      WHERE token_hash = $1
        AND provider = $2
        AND used_at IS NULL
        AND expires_at > NOW()
      LIMIT 1
      `,
      [tokenHash, provider],
    );
    return rows[0] ?? null;
  }

  async markUsed(id) {
    const { rows } = await this.db.query(
      `
      UPDATE account_link_tokens
      SET used_at = NOW()
      WHERE id = $1
      RETURNING *
      `,
      [id],
    );
    return rows[0] ?? null;
  }
}
