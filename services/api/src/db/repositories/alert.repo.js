import { BaseRepository } from "./base.repository.js";

function serializeJsonb(value, fallback) {
  return JSON.stringify(value ?? fallback);
}

export class AlertRepository extends BaseRepository {
  constructor(db) {
    super(db, "alerts", "id");
  }

  async create(row) {
    const { rows } = await this.db.query(
      `
      INSERT INTO alerts (
        user_id,
        rule_id,
        wallet_id,
        wallet_address,
        network_id,
        protocol,
        type,
        severity,
        title,
        message,
        previous_hf,
        current_hf,
        payload,
        read_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb, $14)
      RETURNING *
      `,
      [
        row.user_id,
        row.rule_id ?? null,
        row.wallet_id ?? null,
        row.wallet_address ?? null,
        row.network_id ?? null,
        row.protocol ?? "aave",
        row.type,
        row.severity,
        row.title,
        row.message,
        row.previous_hf ?? null,
        row.current_hf ?? null,
        serializeJsonb(row.payload, {}),
        row.read_at ?? null,
      ],
    );
    return rows[0] ?? null;
  }

  async findByUserId(userId, { limit = 50, offset = 0, unreadOnly = false } = {}) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alerts
      WHERE user_id = $1
        AND ($4::boolean = FALSE OR read_at IS NULL)
      ORDER BY created_at DESC, id DESC
      LIMIT $2 OFFSET $3
      `,
      [userId, limit, offset, unreadOnly],
    );
    return rows;
  }

  async findByIdForUser(alertId, userId) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alerts
      WHERE id = $1 AND user_id = $2
      LIMIT 1
      `,
      [alertId, userId],
    );
    return rows[0] ?? null;
  }

  async markRead(alertId, userId, readAt = new Date()) {
    const { rows } = await this.db.query(
      `
      UPDATE alerts
      SET read_at = $3
      WHERE id = $1
        AND user_id = $2
        AND read_at IS NULL
      RETURNING *
      `,
      [alertId, userId, readAt],
    );
    return rows[0] ?? null;
  }

  async createDelivery(row) {
    const { rows } = await this.db.query(
      `
      INSERT INTO alert_deliveries (
        alert_id,
        channel,
        status,
        attempts,
        last_error,
        delivered_at
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
      `,
      [
        row.alert_id,
        row.channel,
        row.status ?? "pending",
        row.attempts ?? 0,
        row.last_error ?? null,
        row.delivered_at ?? null,
      ],
    );
    return rows[0] ?? null;
  }

  async findDeliveriesByAlertId(alertId) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alert_deliveries
      WHERE alert_id = $1
      ORDER BY id ASC
      `,
      [alertId],
    );
    return rows;
  }

  async findPendingDeliveries({ channel = null, limit = 100, maxAttempts = 3 } = {}) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM alert_deliveries
      WHERE status = 'pending'
        AND ($1::text IS NULL OR channel = $1)
        AND attempts < $3
      ORDER BY created_at ASC, id ASC
      LIMIT $2
      `,
      [channel, limit, maxAttempts],
    );
    return rows;
  }

  async findPendingDeliveriesWithContext({
    channel = null,
    limit = 100,
    maxAttempts = 3,
  } = {}) {
    const { rows } = await this.db.query(
      `
      SELECT
        d.id AS delivery_id,
        d.alert_id,
        d.channel,
        d.status AS delivery_status,
        d.attempts,
        d.last_error,
        d.created_at AS delivery_created_at,
        a.id AS alert_row_id,
        a.user_id,
        a.rule_id,
        a.wallet_id,
        a.wallet_address,
        a.network_id,
        a.protocol,
        a.type,
        a.severity,
        a.title,
        a.message,
        a.previous_hf,
        a.current_hf,
        a.payload,
        a.read_at,
        a.created_at AS alert_created_at,
        u.telegram_id,
        n.name AS network_name
      FROM alert_deliveries d
      INNER JOIN alerts a ON a.id = d.alert_id
      INNER JOIN users u ON u.id = a.user_id
      LEFT JOIN networks n ON n.id = a.network_id
      WHERE d.status = 'pending'
        AND ($1::text IS NULL OR d.channel = $1)
        AND d.attempts < $3
      ORDER BY d.created_at ASC, d.id ASC
      LIMIT $2
      `,
      [channel, limit, maxAttempts],
    );
    return rows;
  }

  async claimPendingDelivery(deliveryId, maxAttempts = 3) {
    const { rows } = await this.db.query(
      `
      UPDATE alert_deliveries
      SET status = 'processing', updated_at = NOW()
      WHERE id = $1
        AND status = 'pending'
        AND attempts < $2
      RETURNING *
      `,
      [deliveryId, maxAttempts],
    );
    return rows[0] ?? null;
  }

  async markDeliveryDelivered(deliveryId) {
    const { rows } = await this.db.query(
      `
      UPDATE alert_deliveries
      SET
        status = 'delivered',
        delivered_at = NOW(),
        last_error = NULL,
        updated_at = NOW()
      WHERE id = $1
        AND status = 'processing'
      RETURNING *
      `,
      [deliveryId],
    );
    return rows[0] ?? null;
  }

  async markDeliveryFailed(deliveryId, errorMessage, maxAttempts = 3) {
    const { rows } = await this.db.query(
      `
      UPDATE alert_deliveries
      SET
        attempts = attempts + 1,
        last_error = $2,
        status = CASE
          WHEN attempts + 1 >= $3 THEN 'failed'
          ELSE 'pending'
        END,
        updated_at = NOW()
      WHERE id = $1
        AND status = 'processing'
      RETURNING *
      `,
      [deliveryId, errorMessage, maxAttempts],
    );
    return rows[0] ?? null;
  }

  async markDeliverySkipped(deliveryId, errorMessage) {
    const { rows } = await this.db.query(
      `
      UPDATE alert_deliveries
      SET
        status = 'failed',
        last_error = $2,
        updated_at = NOW()
      WHERE id = $1
        AND status IN ('pending', 'processing')
      RETURNING *
      `,
      [deliveryId, errorMessage],
    );
    return rows[0] ?? null;
  }

  async updateDelivery(deliveryId, fields) {
    const allowedFields = ["status", "attempts", "last_error", "delivered_at"];
    const keys = Object.keys(fields).filter((k) => allowedFields.includes(k));
    if (keys.length === 0) return null;

    const setClause = keys.map((key, i) => `"${key}" = $${i + 2}`).join(", ");
    const values = [deliveryId, ...keys.map((k) => fields[k])];

    const { rows } = await this.db.query(
      `
      UPDATE alert_deliveries
      SET ${setClause}
      WHERE id = $1
      RETURNING *
      `,
      values,
    );
    return rows[0] ?? null;
  }
}
