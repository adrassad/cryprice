//src/db/postgres.client.js
import pkg from 'pg';
import { ENV } from '../config/env.js';
import { DbClient } from './db.client.js';

const { Pool } = pkg;

export class PostgresClient extends DbClient {
  constructor() {
    super();
    if (!ENV.DATABASE_URL) {
      throw new Error(
        "DATABASE_URL is required but missing. Set it in the environment before starting the application.",
      );
    }
    this.pool = new Pool({
      connectionString: ENV.DATABASE_URL,
    });
  }

  async query(text, params) {
    return this.pool.query(text, params);
  }
}