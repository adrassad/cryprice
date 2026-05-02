import { BaseRepository } from "./base.repository.js";

export class UserRepository extends BaseRepository {
  constructor(db) {
    super(db, "users", "telegram_id");
  }

  /**
   * Lookup by internal app user id (`users.id`). Phase 1+: use for future JWT / linking;
   * existing code still keys by `telegram_id`.
   */
  async findByInternalId(internalId) {
    const { rows } = await this.db.query(
      `SELECT * FROM users WHERE id = $1 LIMIT 1`,
      [internalId],
    );
    return rows[0] ?? null;
  }

  /**
   * Telegram bot: create user from ctx.from (fields: id, username, first_name, last_name).
   */
  async create(user) {
    const result = await this.db.query(
      `
      INSERT INTO users (
        telegram_id,
        username,
        first_name,
        last_name,
        subscription_level,
        subscription_end
      )
      VALUES (
        $1,
        $2,
        $3,
        $4,
        'free',
        NULL
      )
      ON CONFLICT (telegram_id) DO NOTHING
      RETURNING *
      `,
      [user.id, user.username, user.first_name, user.last_name],
    );
    return result.rows[0] || null;
  }

  /**
   * Next negative surrogate telegram_id for Google/API-only users (sequence users_api_telegram_id_seq).
   */
  async nextApiTelegramId() {
    const { rows } = await this.db.query(
      `SELECT nextval('users_api_telegram_id_seq')::bigint AS tid`,
    );
    return rows[0].tid;
  }

  /**
   * Create row for Google sign-in (synthetic negative telegram_id, no Telegram account).
   */
  async createApiUser(fields) {
    const telegramId = await this.nextApiTelegramId();
    const result = await this.db.query(
      `
      INSERT INTO users (
        telegram_id,
        username,
        first_name,
        last_name,
        subscription_level,
        subscription_end,
        email,
        email_verified,
        avatar_url
      )
      VALUES ($1, $2, $3, $4, 'free', NULL, $5, $6, $7)
      RETURNING *
      `,
      [
        telegramId,
        fields.username ?? null,
        fields.first_name ?? null,
        fields.last_name ?? null,
        fields.email ?? null,
        Boolean(fields.email_verified),
        fields.avatar_url ?? null,
      ],
    );
    return result.rows[0] || null;
  }

  /** Telegram profile fields from bot ctx.from updates. */
  async update(telegramId, fields) {
    const allowed = ["username", "first_name", "last_name"];
    return super.update(telegramId, fields, allowed);
  }

  async updateProfile(telegramId, fields) {
    const allowed = [
      "username",
      "first_name",
      "last_name",
      "email",
      "email_verified",
      "avatar_url",
    ];
    return super.update(telegramId, fields, allowed);
  }

  async updateUser(id, fields) {
    const allowedFields = ["threshold_hf"];
    return super.update(id, fields, allowedFields);
  }
}
