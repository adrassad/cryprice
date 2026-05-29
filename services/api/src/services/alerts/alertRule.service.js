import { HttpError } from "../../api/errors/httpError.js";
import { db } from "../../db/index.js";
import { HEALTH_FACTOR_RULE_TYPE } from "./healthFactorAlert.utils.js";
import { assertWalletOwnedByInternalUser } from "../portfolio/portfolio.service.js";

const THRESHOLD_HF_MIN = 0.01;
const THRESHOLD_HF_MAX = 9999.99;
const COOLDOWN_MINUTES_MIN = 1;
const COOLDOWN_MINUTES_MAX = 10_080;
const DEFAULT_COOLDOWN_MINUTES = 30;

function parseThresholdHf(value, { required = false } = {}) {
  if (value === undefined || value === null) {
    if (required) {
      throw new HttpError(400, "INVALID_BODY", "threshold_hf is required.");
    }
    return undefined;
  }
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0 || n < THRESHOLD_HF_MIN || n > THRESHOLD_HF_MAX) {
    throw new HttpError(
      400,
      "INVALID_REQUEST",
      `threshold_hf must be between ${THRESHOLD_HF_MIN} and ${THRESHOLD_HF_MAX}.`,
    );
  }
  return n;
}

function parseCooldownMinutes(value, { defaultValue = DEFAULT_COOLDOWN_MINUTES } = {}) {
  if (value === undefined || value === null) return defaultValue;
  const n = Number(value);
  if (
    !Number.isFinite(n) ||
    !Number.isInteger(n) ||
    n < COOLDOWN_MINUTES_MIN ||
    n > COOLDOWN_MINUTES_MAX
  ) {
    throw new HttpError(
      400,
      "INVALID_REQUEST",
      `cooldown_minutes must be an integer between ${COOLDOWN_MINUTES_MIN} and ${COOLDOWN_MINUTES_MAX}.`,
    );
  }
  return n;
}

function parseOptionalId(value, fieldName) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  const s = String(value).trim();
  if (!s) {
    throw new HttpError(400, "INVALID_REQUEST", `${fieldName} must be a positive integer or null.`);
  }
  const n = Number(s);
  if (!Number.isFinite(n) || n <= 0 || !Number.isInteger(n)) {
    throw new HttpError(400, "INVALID_REQUEST", `${fieldName} must be a positive integer or null.`);
  }
  return n;
}

function parseBoolean(value, fieldName) {
  if (value === undefined || value === null) return undefined;
  if (typeof value === "boolean") return value;
  if (value === "true" || value === "1") return true;
  if (value === "false" || value === "0") return false;
  throw new HttpError(400, "INVALID_REQUEST", `${fieldName} must be a boolean.`);
}

async function assertNetworkExists(networkId) {
  const network = await db.networks.findById(networkId);
  if (!network) {
    throw new HttpError(404, "NETWORK_NOT_FOUND", "Network not found.");
  }
  return network;
}

async function validateWalletScope(userId, walletId) {
  if (walletId == null) return;
  await assertWalletOwnedByInternalUser(userId, walletId);
}

export function serializeAlertRuleForApi(row) {
  if (!row) return null;
  return {
    id: String(row.id),
    user_id: String(row.user_id),
    type: row.type,
    protocol: row.protocol,
    wallet_id: row.wallet_id != null ? String(row.wallet_id) : null,
    network_id: row.network_id != null ? String(row.network_id) : null,
    threshold_hf: row.threshold_hf != null ? String(row.threshold_hf) : null,
    direction: row.direction,
    enabled: row.enabled,
    cooldown_minutes: row.cooldown_minutes,
    last_triggered_at:
      row.last_triggered_at instanceof Date
        ? row.last_triggered_at.toISOString()
        : row.last_triggered_at != null
          ? String(row.last_triggered_at)
          : null,
    created_at:
      row.created_at instanceof Date
        ? row.created_at.toISOString()
        : row.created_at != null
          ? String(row.created_at)
          : null,
    updated_at:
      row.updated_at instanceof Date
        ? row.updated_at.toISOString()
        : row.updated_at != null
          ? String(row.updated_at)
          : null,
  };
}

export function parseCreateAlertRuleBody(body) {
  if (body == null || typeof body !== "object" || Array.isArray(body)) {
    throw new HttpError(400, "INVALID_BODY", "JSON object body is required.");
  }

  const threshold_hf = parseThresholdHf(body.threshold_hf, { required: true });
  const wallet_id = parseOptionalId(body.wallet_id, "wallet_id");
  const network_id = parseOptionalId(body.network_id, "network_id");
  const enabled = parseBoolean(body.enabled, "enabled");
  const cooldown_minutes = parseCooldownMinutes(body.cooldown_minutes);

  const type =
    body.type === undefined || body.type === null || body.type === ""
      ? HEALTH_FACTOR_RULE_TYPE
      : String(body.type).trim();
  if (type !== HEALTH_FACTOR_RULE_TYPE) {
    throw new HttpError(400, "INVALID_REQUEST", `type must be ${HEALTH_FACTOR_RULE_TYPE}.`);
  }

  const protocol =
    body.protocol === undefined || body.protocol === null || body.protocol === ""
      ? "aave"
      : String(body.protocol).trim();

  const direction =
    body.direction === undefined || body.direction === null || body.direction === ""
      ? "below"
      : String(body.direction).trim();
  if (direction !== "below") {
    throw new HttpError(400, "INVALID_REQUEST", "direction must be below.");
  }

  return {
    type,
    protocol,
    wallet_id: wallet_id ?? null,
    network_id: network_id ?? null,
    threshold_hf,
    direction,
    enabled: enabled ?? true,
    cooldown_minutes,
  };
}

export function parsePatchAlertRuleBody(body) {
  if (body == null || typeof body !== "object" || Array.isArray(body)) {
    throw new HttpError(400, "INVALID_BODY", "JSON object body is required.");
  }

  const allowed = ["enabled", "threshold_hf", "cooldown_minutes", "wallet_id", "network_id"];
  const keys = Object.keys(body).filter((k) => allowed.includes(k));
  if (keys.length === 0) {
    throw new HttpError(400, "INVALID_BODY", "At least one updatable field is required.");
  }

  const out = {};
  if (Object.prototype.hasOwnProperty.call(body, "enabled")) {
    out.enabled = parseBoolean(body.enabled, "enabled");
  }
  if (Object.prototype.hasOwnProperty.call(body, "threshold_hf")) {
    out.threshold_hf = parseThresholdHf(body.threshold_hf, { required: true });
  }
  if (Object.prototype.hasOwnProperty.call(body, "cooldown_minutes")) {
    out.cooldown_minutes = parseCooldownMinutes(body.cooldown_minutes);
  }
  if (Object.prototype.hasOwnProperty.call(body, "wallet_id")) {
    out.wallet_id = parseOptionalId(body.wallet_id, "wallet_id");
  }
  if (Object.prototype.hasOwnProperty.call(body, "network_id")) {
    out.network_id = parseOptionalId(body.network_id, "network_id");
  }
  return out;
}

export async function listAlertRulesForUser(userId) {
  const rows = await db.alertRules.findByUserId(userId);
  return rows.map(serializeAlertRuleForApi);
}

export async function createAlertRuleForUser(userId, body) {
  const input = parseCreateAlertRuleBody(body);
  await validateWalletScope(userId, input.wallet_id);
  if (input.network_id != null) {
    await assertNetworkExists(input.network_id);
  }

  const row = await db.alertRules.create({
    user_id: userId,
    ...input,
  });
  return serializeAlertRuleForApi(row);
}

export async function patchAlertRuleForUser(userId, ruleId, body) {
  const existing = await db.alertRules.findByIdForUser(ruleId, userId);
  if (!existing) {
    throw new HttpError(404, "ALERT_RULE_NOT_FOUND", "Alert rule not found.");
  }

  const patch = parsePatchAlertRuleBody(body);

  if (Object.prototype.hasOwnProperty.call(patch, "wallet_id")) {
    await validateWalletScope(userId, patch.wallet_id);
  }
  if (Object.prototype.hasOwnProperty.call(patch, "network_id") && patch.network_id != null) {
    await assertNetworkExists(patch.network_id);
  }

  const updated = await db.alertRules.updateForUser(userId, ruleId, patch);
  if (!updated) {
    throw new HttpError(404, "ALERT_RULE_NOT_FOUND", "Alert rule not found.");
  }
  return serializeAlertRuleForApi(updated);
}
