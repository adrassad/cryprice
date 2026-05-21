// Single shared PostgreSQL client (one pool) for schema init and repositories.
import { PostgresClient } from "./postgres.client.js";

export const postgresClient = new PostgresClient();
