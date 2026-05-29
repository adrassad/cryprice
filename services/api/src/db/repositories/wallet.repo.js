// src/db/repositories/wallet.repo.js
import { BaseRepository } from "./base.repository.js";

export class WalletRepository extends BaseRepository {
  constructor(db) {
    super(db, "wallets", "id");
  }
  async create(object) {
    const result = await this.db.query(
      `
    INSERT INTO wallets (user_id, address, label)
        VALUES ($1, $2, $3)
        ON CONFLICT (user_id, address) DO NOTHING
        RETURNING *
    `,
      [object.user_id, object.address, object.label],
    );
    return result.rows[0] || null;
  }

  async deleteUserWallet(userId, address) {
    const res = await this.db.query(
      `
        DELETE FROM wallets
        WHERE address = $1 AND user_id = $2
        RETURNING *
        `,
      [address, userId],
    );
    return res.rows[0] || null;
  }

  async walletExists(userId, address) {
    const res = await this.db.query(
      `
        SELECT 1
        FROM wallets
        WHERE user_id = $1 AND address = $2
        LIMIT 1
        `,
      [userId, address.toLowerCase()],
    );
    return res.rowCount > 0;
  }

  async countByUserId(userId) {
    const { rows } = await this.db.query(
      `
      SELECT COUNT(*)::int AS count
      FROM wallets
      WHERE user_id = $1
      `,
      [userId],
    );
    return rows[0]?.count ?? 0;
  }

  async findByUserId(userId) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM wallets
      WHERE user_id = $1
      ORDER BY id ASC
      `,
      [userId],
    );
    return rows;
  }

  async findAllByAddress(address) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM wallets
      WHERE LOWER(address) = LOWER($1)
      ORDER BY user_id ASC, id ASC
      `,
      [address],
    );
    return rows;
  }

  async findByUserAndAddress(userId, address) {
    const { rows } = await this.db.query(
      `
      SELECT *
      FROM wallets
      WHERE user_id = $1 AND address = $2
      LIMIT 1
      `,
      [userId, address.toLowerCase()],
    );
    return rows[0] ?? null;
  }

  async updateLabelForUser(telegramUserId, walletId, label) {
    const res = await this.db.query(
      `
      UPDATE wallets
      SET label = $3
      WHERE id = $1 AND user_id = $2
      RETURNING *
      `,
      [walletId, telegramUserId, label],
    );
    return res.rows[0] ?? null;
  }

  async deleteWalletByIdForUser(telegramUserId, walletId) {
    const res = await this.db.query(
      `
      DELETE FROM wallets
      WHERE id = $1 AND user_id = $2
      RETURNING *
      `,
      [walletId, telegramUserId],
    );
    return res.rows[0] ?? null;
  }
}
