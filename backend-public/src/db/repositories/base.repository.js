export class BaseRepository {
  constructor(db, tableName, idColumn = "id") {
    if (!db) throw new Error("db is required");
    if (!tableName) throw new Error("tableName is required");
    if (!idColumn) throw new Error("idColumn is required");

    this.db = db;
    this.tableName = tableName;
    this.idColumn = idColumn;

    Object.freeze(this);
  }

  // -------------------------
  // helpers
  // -------------------------

  _assertId(id) {
    if (id === undefined || id === null) throw new Error("id is required");
  }

  _assertObject(obj, name = "object") {
    if (!obj || typeof obj !== "object")
      throw new Error(`${name} must be object`);
  }

  // -------------------------
  // basic queries
  // -------------------------

  async findById(id) {
    this._assertId(id);

    const { rows } = await this.db.query(
      `SELECT *
       FROM ${this.tableName}
       WHERE ${this.idColumn} = $1
       LIMIT 1`,
      [id],
    );

    return rows[0] ?? null;
  }

  async exists(id) {
    this._assertId(id);

    const { rows } = await this.db.query(
      `SELECT EXISTS(
         SELECT 1
         FROM ${this.tableName}
         WHERE ${this.idColumn} = $1
       ) AS exists`,
      [id],
    );

    return rows[0].exists;
  }

  async countAll() {
    const { rows } = await this.db.query(
      `SELECT COUNT(*)::int AS count
       FROM ${this.tableName}`,
    );

    return rows[0].count;
  }

  async findAll({ limit = 1000, offset = 0 } = {}) {
    if (limit < 0) throw new Error("limit must be >= 0");
    if (offset < 0) throw new Error("offset must be >= 0");

    const { rows } = await this.db.query(
      `SELECT *
       FROM ${this.tableName}
       ORDER BY ${this.idColumn}
       LIMIT $1 OFFSET $2`,
      [limit, offset],
    );

    return rows;
  }

  async delete(id) {
    this._assertId(id);

    const { rows } = await this.db.query(
      `DELETE FROM ${this.tableName}
       WHERE ${this.idColumn} = $1
       RETURNING *`,
      [id],
    );

    return rows[0] ?? null;
  }

  async update(id, fields, allowedFields = null) {
    this._assertId(id);
    this._assertObject(fields, "fields");

    const keys = Object.keys(fields);

    if (keys.length === 0) return null;

    const allowed = allowedFields ? new Set(allowedFields) : null;

    const safeKeys = allowed ? keys.filter((k) => allowed.has(k)) : keys;

    if (safeKeys.length === 0) return null;

    const setClause = safeKeys
      .map((key, i) => `"${key}" = $${i + 2}`)
      .join(", ");

    const values = [id, ...safeKeys.map((k) => fields[k])];

    const { rows } = await this.db.query(
      `
      UPDATE ${this.tableName}
      SET ${setClause}
      WHERE ${this.idColumn} = $1
      RETURNING *
      `,
      values,
    );

    return rows[0] ?? null;
  }
}
