import { db } from "../../db/index.js";
import { NotificationService } from "../../bot/notification.service.js";
import { formatAlertForTelegram } from "./alertTelegram.formatter.js";

const DEFAULT_LIMIT = 50;
const DEFAULT_MAX_ATTEMPTS = 3;

function buildAlertFromRow(row) {
  return {
    id: row.alert_row_id,
    user_id: row.user_id,
    rule_id: row.rule_id,
    wallet_id: row.wallet_id,
    wallet_address: row.wallet_address,
    network_id: row.network_id,
    protocol: row.protocol,
    type: row.type,
    severity: row.severity,
    title: row.title,
    message: row.message,
    previous_hf: row.previous_hf,
    current_hf: row.current_hf,
    payload: row.payload ?? {},
    read_at: row.read_at,
    created_at: row.alert_created_at,
  };
}

async function deliverOneTelegram(row, { maxAttempts }) {
  const deliveryId = row.delivery_id;

  const claimed = await db.alerts.claimPendingDelivery(deliveryId, maxAttempts);
  if (!claimed) {
    return { outcome: "skipped", reason: "not_claimable" };
  }

  if (row.telegram_id == null) {
    await db.alerts.markDeliverySkipped(deliveryId, "missing_telegram_id");
    console.log("[Alert Delivery] skipped", {
      deliveryId,
      alertId: row.alert_id,
      reason: "missing_telegram_id",
    });
    return { outcome: "skipped", reason: "missing_telegram_id" };
  }

  const alert = buildAlertFromRow(row);
  const message = formatAlertForTelegram({
    alert,
    networkName: row.network_name,
  });

  const result = await NotificationService.sendToUser(
    row.telegram_id,
    message,
    { parse_mode: "HTML" },
  );

  if (result?.ok) {
    const delivered = await db.alerts.markDeliveryDelivered(deliveryId);
    if (!delivered) {
      return { outcome: "skipped", reason: "delivered_state_lost" };
    }
    console.log("[Alert Delivery] delivered", {
      deliveryId,
      alertId: row.alert_id,
      telegramId: row.telegram_id,
    });
    return { outcome: "delivered" };
  }

  const failed = await db.alerts.markDeliveryFailed(
    deliveryId,
    result?.error ?? "send_failed",
    maxAttempts,
  );
  console.log("[Alert Delivery] failed", {
    deliveryId,
    alertId: row.alert_id,
    attempts: failed?.attempts ?? null,
    status: failed?.status ?? null,
    error: result?.error ?? "send_failed",
  });
  return { outcome: "failed", error: result?.error ?? "send_failed" };
}

/**
 * Deliver pending alert_deliveries for a channel.
 * Does not evaluate alerts — persistence must already exist.
 *
 * @param {Object} [options]
 * @param {string} [options.channel='telegram']
 * @param {number} [options.limit=50]
 * @param {number} [options.maxAttempts=3]
 */
export async function deliverPendingAlerts({
  channel = "telegram",
  limit = DEFAULT_LIMIT,
  maxAttempts = DEFAULT_MAX_ATTEMPTS,
} = {}) {
  console.log("[Alert Delivery] started", {
    channel,
    limit,
    maxAttempts,
    at: new Date().toISOString(),
  });

  const stats = {
    scanned: 0,
    delivered: 0,
    failed: 0,
    skipped: 0,
  };

  const rows = await db.alerts.findPendingDeliveriesWithContext({
    channel,
    limit,
    maxAttempts,
  });

  stats.scanned = rows.length;

  for (const row of rows) {
    try {
      const result = await deliverOneTelegram(row, { maxAttempts });
      if (result.outcome === "delivered") stats.delivered += 1;
      else if (result.outcome === "failed") stats.failed += 1;
      else stats.skipped += 1;
    } catch (err) {
      stats.failed += 1;
      try {
        await db.alerts.markDeliveryFailed(
          row.delivery_id,
          err?.message ?? String(err),
          maxAttempts,
        );
      } catch (updateErr) {
        console.error("[Alert Delivery] failed to record error", {
          deliveryId: row.delivery_id,
          error: updateErr?.message ?? updateErr,
        });
      }
      console.log("[Alert Delivery] failed", {
        deliveryId: row.delivery_id,
        alertId: row.alert_id,
        error: err?.message ?? err,
      });
    }
  }

  console.log("[Alert Delivery] finished", stats);
  return stats;
}
