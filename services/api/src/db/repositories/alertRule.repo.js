import { BaseRepository } from "./base.repository.js";

export class AlertRuleRepository extends BaseRepository {
  constructor(db) {
    super(db, "alert_rules", "id");
  }

  async create(row) {
    const { rows } = await this.db.query(
      `
      INSERT INTO alert_rules (
        user_id,
        type,
        protocol,
        wallet_id,
        network_id,
        threshold_hf,
        direction,
        enabled,
        cooldown_minutes,
        last_triggered_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
      `,
      [
        row.user_id,
        row.type,
        row.protocol ?? "aave",
        row.wallet_id ?? null,
        row.network_id ?? null,
        row.threshold_hf ?? null,
        row.direction ?? "below",
        row.enabled ?? true,
        row.cooldown_minutes ?? 30,
        row.last_triggered_at ?? null,
      ],
    );
    return rows[0] ?? null;
  }

  async findAllEnabled() {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alert_rules
      WHERE enabled = TRUE
      ORDER BY user_id ASC, id ASC
      `,
    );
    return rows;
  }

  async findByUserId(userId, { enabledOnly = false } = {}) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alert_rules
      WHERE user_id = $1
        AND ($2::boolean = FALSE OR enabled = TRUE)
      ORDER BY id ASC
      `,
      [userId, enabledOnly],
    );
    return rows;
  }

  async findByIdForUser(ruleId, userId) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alert_rules
      WHERE id = $1 AND user_id = $2
      LIMIT 1
      `,
      [ruleId, userId],
    );
    return rows[0] ?? null;
  }

  async updateForUser(userId, ruleId, fields) {
    const allowedFields = new Set([
      "type",
      "protocol",
      "wallet_id",
      "network_id",
      "threshold_hf",
      "direction",
      "enabled",
      "cooldown_minutes",
      "last_triggered_at",
    ]);
    const keys = Object.keys(fields).filter((k) => allowedFields.has(k));
    if (keys.length === 0) return null;

    const setClause = keys.map((key, i) => `"${key}" = $${i + 3}`).join(", ");
    const values = [ruleId, userId, ...keys.map((k) => fields[k])];

    const { rows } = await this.db.query(
      `
      UPDATE alert_rules
      SET ${setClause}
      WHERE id = $1 AND user_id = $2
      RETURNING *
      `,
      values,
    );
    return rows[0] ?? null;
  }

  async updateLastTriggeredAt(ruleId, triggeredAt = new Date()) {
    const { rows } = await this.db.query(
      `
      UPDATE alert_rules
      SET last_triggered_at = $2
      WHERE id = $1
      RETURNING *
      `,
      [ruleId, triggeredAt],
    );
    return rows[0] ?? null;
  }
}
