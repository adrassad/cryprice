import { db } from "../../db/index.js";
import { getUserByInternalId } from "../user/user.service.js";
import {
  HEALTH_FACTOR_RULE_TYPE,
  buildAlertCopy,
  evaluateHfTransition,
  formatHfForStorage,
  hasSeverityWorsened,
  isCooldownActive,
  isSnapshotAlreadyProcessed,
  shouldSuppressAlertByCooldown,
} from "./healthFactorAlert.utils.js";

function hfPairKey(address, protocol, networkId) {
  return `${String(address).toLowerCase()}|${protocol}|${networkId}`;
}

function groupLatestTwoRows(rows) {
  const map = new Map();
  for (const row of rows) {
    const key = hfPairKey(row.address, row.protocol, row.network_id);
    if (!map.has(key)) {
      map.set(key, { current: null, previous: null, latestCreatedAt: null });
    }
    const entry = map.get(key);
    if (Number(row.rn) === 1) {
      entry.current = row.healthfactor;
      entry.latestCreatedAt = row.created_at;
    } else if (Number(row.rn) === 2) {
      entry.previous = row.healthfactor;
    }
  }
  return map;
}

function ruleMatchesScope(rule, { walletId, networkId, protocol }) {
  if (rule.protocol && rule.protocol !== protocol) return false;
  if (rule.wallet_id != null && String(rule.wallet_id) !== String(walletId)) {
    return false;
  }
  if (rule.network_id != null && String(rule.network_id) !== String(networkId)) {
    return false;
  }
  return true;
}

function isHealthFactorRule(rule) {
  return (
    rule?.type === HEALTH_FACTOR_RULE_TYPE &&
    rule?.direction === "below" &&
    rule?.threshold_hf != null
  );
}

async function createAlertWithDeliveries({
  userId,
  rule,
  wallet,
  networkId,
  protocol,
  transition,
  snapshotCreatedAt,
}) {
  const copy = buildAlertCopy(transition, {
    thresholdHf: rule.threshold_hf,
    protocol,
  });

  const alert = await db.alerts.create({
    user_id: userId,
    rule_id: rule.id,
    wallet_id: wallet?.id ?? null,
    wallet_address: wallet?.address ?? null,
    network_id: networkId,
    protocol,
    type: transition.alertType,
    severity: transition.severity,
    title: copy.title,
    message: copy.message,
    previous_hf: formatHfForStorage(transition.previousHf),
    current_hf: formatHfForStorage(transition.currentHf),
    payload: {
      threshold_hf: Number(rule.threshold_hf),
      transition: transition.kind,
    },
  });

  await db.alerts.createDelivery({ alert_id: alert.id, channel: "in_app" });

  const user = await getUserByInternalId(userId);
  if (user?.telegram_id != null) {
    await db.alerts.createDelivery({ alert_id: alert.id, channel: "telegram" });
  }

  await db.alertRules.updateLastTriggeredAt(
    rule.id,
    snapshotCreatedAt ?? new Date(),
  );

  console.log("[HF Alert] alert created", {
    alertId: alert.id,
    userId,
    ruleId: rule.id,
    type: transition.alertType,
    severity: transition.severity,
    walletId: wallet?.id ?? null,
    networkId,
  });

  return alert;
}

async function evaluateRuleWalletNetwork({
  rule,
  wallet,
  networkId,
  protocol,
  previousHf,
  currentHf,
  snapshotCreatedAt,
  stats,
}) {
  if (!ruleMatchesScope(rule, { walletId: wallet.id, networkId, protocol })) {
    return;
  }

  if (isSnapshotAlreadyProcessed(snapshotCreatedAt, rule.last_triggered_at)) {
    stats.skippedDuplicate += 1;
    return;
  }

  const transition = evaluateHfTransition({
    previousHf,
    currentHf,
    thresholdHf: rule.threshold_hf,
    rule,
  });

  if (transition.kind === "skip") {
    console.log("[HF Alert] skipped due to invalid HF", {
      ruleId: rule.id,
      userId: rule.user_id,
      walletId: wallet.id,
      networkId,
      reason: transition.reason,
    });
    stats.skippedInvalid += 1;
    return;
  }

  if (transition.kind === "none") {
    if (transition.reason === "above_threshold") {
      console.log("[HF Alert] skipped because current HF above threshold", {
        ruleId: rule.id,
        userId: rule.user_id,
        walletId: wallet.id,
        networkId,
        currentHf,
        thresholdHf: rule.threshold_hf,
      });
    }
    return;
  }

  if (
    shouldSuppressAlertByCooldown(transition, rule, { previousHf, currentHf })
  ) {
    console.log("[HF Alert] skipped due to cooldown", {
      ruleId: rule.id,
      userId: rule.user_id,
      walletId: wallet.id,
      networkId,
      alertType: transition.alertType,
    });
    stats.skippedCooldown += 1;
    return;
  }

  const severityWorsened =
    transition.kind === "breach" &&
    hasSeverityWorsened(previousHf, currentHf) &&
    isCooldownActive(rule);

  await createAlertWithDeliveries({
    userId: rule.user_id,
    rule,
    wallet,
    networkId,
    protocol,
    transition,
    snapshotCreatedAt,
  });
  stats.created += 1;

  if (transition.kind === "recovery") {
    console.log("[HF Alert] created recovery alert", {
      ruleId: rule.id,
      userId: rule.user_id,
      walletId: wallet.id,
      networkId,
      previousHf,
      currentHf,
    });
  } else if (severityWorsened) {
    console.log("[HF Alert] created severity-worsened alert", {
      ruleId: rule.id,
      userId: rule.user_id,
      walletId: wallet.id,
      networkId,
      previousHf,
      currentHf,
      severity: transition.severity,
    });
  } else {
    console.log("[HF Alert] created below-threshold alert", {
      ruleId: rule.id,
      userId: rule.user_id,
      walletId: wallet.id,
      networkId,
      previousHf,
      currentHf,
      reason: transition.reason,
      severity: transition.severity,
    });
  }
}

async function evaluateExplicitChanges(changes, stats) {
  for (const change of changes) {
    if (change.isChanged === false) continue;

    const protocol = change.protocol ?? "aave";
    const wallets = await db.wallets.findAllByAddress(change.address);

    for (const wallet of wallets) {
      const rules = (await db.alertRules.findByUserId(wallet.user_id, {
        enabledOnly: true,
      })).filter(isHealthFactorRule);

      for (const rule of rules) {
        await evaluateRuleWalletNetwork({
          rule,
          wallet,
          networkId: change.networkId,
          protocol,
          previousHf: change.previousHf,
          currentHf: change.currentHf,
          snapshotCreatedAt: change.snapshotCreatedAt ?? new Date(),
          stats,
        });
      }
    }
  }
}

async function evaluateFromStoredHistory(stats) {
  const rules = (await db.alertRules.findAllEnabled()).filter(isHealthFactorRule);
  if (!rules.length) return;

  const walletsByUser = new Map();
  for (const rule of rules) {
    if (!walletsByUser.has(rule.user_id)) {
      walletsByUser.set(rule.user_id, await db.wallets.findByUserId(rule.user_id));
    }
  }

  const addresses = [
    ...new Set(
      rules.flatMap((rule) => {
        const wallets = walletsByUser.get(rule.user_id) ?? [];
        if (rule.wallet_id != null) {
          const wallet = wallets.find((w) => String(w.id) === String(rule.wallet_id));
          return wallet ? [wallet.address] : [];
        }
        return wallets.map((w) => w.address);
      }),
    ),
  ];

  if (!addresses.length) return;

  const hfRows = await db.hf.findLatestTwoByAddresses(addresses, { protocol: "aave" });
  const hfPairs = groupLatestTwoRows(hfRows);

  for (const rule of rules) {
    const wallets = walletsByUser.get(rule.user_id) ?? [];
    const scopedWallets =
      rule.wallet_id != null
        ? wallets.filter((w) => String(w.id) === String(rule.wallet_id))
        : wallets;

    for (const wallet of scopedWallets) {
      const networkIds = rule.network_id != null
        ? [rule.network_id]
        : [...new Set(hfRows
            .filter((r) => r.address === wallet.address.toLowerCase())
            .map((r) => r.network_id))];

      for (const networkId of networkIds) {
        const pair = hfPairs.get(
          hfPairKey(wallet.address.toLowerCase(), rule.protocol ?? "aave", networkId),
        );
        if (pair?.current == null) {
          continue;
        }

        await evaluateRuleWalletNetwork({
          rule,
          wallet,
          networkId,
          protocol: rule.protocol ?? "aave",
          previousHf: pair.previous ?? null,
          currentHf: pair.current,
          snapshotCreatedAt: pair.latestCreatedAt,
          stats,
        });
      }
    }
  }
}

/**
 * Evaluate HF threshold transitions and persist alerts + delivery rows.
 * Does not send messages.
 *
 * @param {Object} [options]
 * @param {Array<{
 *   address: string,
 *   networkId: number,
 *   protocol?: string,
 *   previousHf: number | typeof Infinity | null,
 *   currentHf: number | typeof Infinity | null,
 *   isChanged?: boolean,
 *   snapshotCreatedAt?: Date | string,
 * }>} [options.changes] Explicit HF changes; when omitted, reads latest two DB samples.
 */
export async function evaluateHealthFactorAlerts({ changes = null } = {}) {
  console.log("[HF Alert] evaluation started", {
    mode: Array.isArray(changes) ? "explicit" : "history",
    changeCount: Array.isArray(changes) ? changes.length : null,
    at: new Date().toISOString(),
  });

  const stats = {
    created: 0,
    skippedCooldown: 0,
    skippedInvalid: 0,
    skippedDuplicate: 0,
  };

  if (Array.isArray(changes)) {
    if (changes.length > 0) {
      await evaluateExplicitChanges(changes, stats);
    }
  } else {
    await evaluateFromStoredHistory(stats);
  }

  console.log("[HF Alert] evaluation finished", stats);
  return stats;
}

export { evaluateHfTransition } from "./healthFactorAlert.utils.js";
