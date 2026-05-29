import { HttpError } from "../../api/errors/httpError.js";
import { db } from "../../db/index.js";

const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 100;

function parseAlertPayload(value) {
  if (value == null) return {};
  if (typeof value === "object" && !Array.isArray(value)) {
    return value;
  }
  if (typeof value === "string") {
    try {
      const parsed = JSON.parse(value);
      return typeof parsed === "object" && parsed != null && !Array.isArray(parsed)
        ? parsed
        : {};
    } catch {
      return {};
    }
  }
  return {};
}

function parsePositiveIntParam(value, fallback) {
  if (value === undefined || value === null || value === "") return fallback;
  const n = Number(value);
  if (!Number.isFinite(n) || n < 0 || !Number.isInteger(n)) {
    throw new HttpError(400, "INVALID_REQUEST", "limit and offset must be non-negative integers.");
  }
  return n;
}

function parseUnreadOnly(value) {
  if (value === undefined || value === null || value === "") return false;
  if (value === "true" || value === true || value === "1") return true;
  if (value === "false" || value === false || value === "0") return false;
  throw new HttpError(400, "INVALID_REQUEST", "unread must be true or false.");
}

export function serializeAlertForApi(row) {
  if (!row) return null;

  return {
    id: String(row.id),
    user_id: String(row.user_id),
    rule_id: row.rule_id != null ? String(row.rule_id) : null,
    wallet_id: row.wallet_id != null ? String(row.wallet_id) : null,
    wallet_address: row.wallet_address ?? null,
    network_id: row.network_id != null ? String(row.network_id) : null,
    protocol: row.protocol,
    type: row.type,
    severity: row.severity,
    title: row.title,
    message: row.message,
    previous_hf: row.previous_hf != null ? String(row.previous_hf) : null,
    current_hf: row.current_hf != null ? String(row.current_hf) : null,
    payload: parseAlertPayload(row.payload),
    read_at:
      row.read_at instanceof Date
        ? row.read_at.toISOString()
        : row.read_at != null
          ? String(row.read_at)
          : null,
    created_at:
      row.created_at instanceof Date
        ? row.created_at.toISOString()
        : row.created_at != null
          ? String(row.created_at)
          : null,
  };
}

export function parseListAlertsQuery(query) {
  const unreadOnly = parseUnreadOnly(query?.unread);
  let limit = parsePositiveIntParam(query?.limit, DEFAULT_LIMIT);
  const offset = parsePositiveIntParam(query?.offset, 0);
  if (limit < 1) limit = DEFAULT_LIMIT;
  if (limit > MAX_LIMIT) limit = MAX_LIMIT;
  return { unreadOnly, limit, offset };
}

export async function listAlertsForUser(userId, query = {}) {
  const { unreadOnly, limit, offset } = parseListAlertsQuery(query);
  const rows = await db.alerts.findByUserId(userId, { unreadOnly, limit, offset });
  return rows.map(serializeAlertForApi);
}

export async function markAlertReadForUser(userId, alertId) {
  const existing = await db.alerts.findByIdForUser(alertId, userId);
  if (!existing) {
    throw new HttpError(404, "ALERT_NOT_FOUND", "Alert not found.");
  }
  if (existing.read_at != null) {
    return serializeAlertForApi(existing);
  }
  const updated = await db.alerts.markRead(alertId, userId);
  return serializeAlertForApi(updated ?? existing);
}
