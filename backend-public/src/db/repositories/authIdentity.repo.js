export class AuthIdentityRepository {
  constructor(db) {
    this.db = db;
  }

  async findByProviderUserId(provider, providerUserId) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM auth_identities
      WHERE provider = $1 AND provider_user_id = $2
      LIMIT 1
      `,
      [provider, providerUserId],
    );
    return rows[0] ?? null;
  }

  async insert(row) {
    const { rows } = await this.db.query(
      `
      INSERT INTO auth_identities (
        provider,
        provider_user_id,
        user_telegram_id,
        user_id,
        email,
        email_verified,
        avatar_url,
        profile_json
      )
      VALUES (
        $1,
        $2,
        $3,
        COALESCE($4, (SELECT u.id FROM users u WHERE u.telegram_id = $3 LIMIT 1)),
        $5,
        $6,
        $7,
        $8::jsonb
      )
      RETURNING *
      `,
      [
        row.provider,
        row.provider_user_id,
        row.user_telegram_id,
        row.user_id ?? null,
        row.email ?? null,
        Boolean(row.email_verified),
        row.avatar_url ?? null,
        row.profile_json != null ? JSON.stringify(row.profile_json) : null,
      ],
    );
    return rows[0] ?? null;
  }

  async updateProfile(id, patch) {
    const { rows } = await this.db.query(
      `
      UPDATE auth_identities
      SET
        email = $2,
        email_verified = $3,
        avatar_url = $4,
        profile_json = $5::jsonb,
        updated_at = NOW()
      WHERE id = $1
      RETURNING *
      `,
      [
        id,
        patch.email ?? null,
        Boolean(patch.email_verified),
        patch.avatar_url ?? null,
        patch.profile_json != null ? JSON.stringify(patch.profile_json) : null,
      ],
    );
    return rows[0] ?? null;
  }
}
