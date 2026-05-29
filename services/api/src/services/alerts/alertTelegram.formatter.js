import { resolveHealthFactorSemanticState } from "./healthFactorAlert.utils.js";

function shortenAddress(address) {
  if (!address || typeof address !== "string") return "n/a";
  const trimmed = address.trim();
  if (trimmed.length < 10) return trimmed;
  return `${trimmed.slice(0, 6)}...${trimmed.slice(-4)}`;
}

function formatHfValue(value) {
  if (value === null || value === undefined || value === "") return "n/a";
  if (typeof value === "string" && value.trim().toLowerCase() === "infinity") {
    return "∞";
  }
  const n = Number(value);
  if (!Number.isFinite(n)) return "∞";
  if (n > 1e20) return "∞";
  return n.toFixed(2);
}

function severityLabel(severity) {
  switch (severity) {
    case "critical":
      return "🚨 Critical";
    case "high":
      return "🔴 High";
    case "warning":
      return "⚠️ Warning";
    case "medium":
      return "🟠 Medium";
    case "low":
      return "🟡 Low";
    case "info":
      return "ℹ️ Info";
    default:
      return String(severity ?? "alert");
  }
}

export function escapeTelegramHtml(text) {
  return String(text ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

const HEALTH_FACTOR_ALERT_TYPES = new Set([
  "health_factor_breach",
  "health_factor_recovery",
]);

function formatNetworkDisplayName(name) {
  if (!name || typeof name !== "string") return "Unknown";
  const trimmed = name.trim();
  if (!trimmed) return "Unknown";
  return trimmed.charAt(0).toUpperCase() + trimmed.slice(1).toLowerCase();
}

function resolveHfNumericForDisplay(value) {
  if (value === null || value === undefined || value === "") return null;
  if (typeof value === "string" && value.trim().toLowerCase() === "infinity") {
    return Infinity;
  }
  const n = Number(value);
  if (!Number.isFinite(n)) {
    return n === Infinity ? Infinity : null;
  }
  if (n > 1e20) return Infinity;
  return n;
}

export function getHFIcon(value) {
  const hf = resolveHfNumericForDisplay(value);
  if (hf === null) return "";
  if (hf === Infinity) return "♾️";
  if (hf > 2) return "💚";
  if (hf > 1.5) return "💛";
  if (hf > 1.2) return "🧡";
  if (hf > 1) return "❤️";
  return "💔";
}

function formatHealthFactorSeverityBlock(alert) {
  const state = resolveHealthFactorSemanticState(alert?.current_hf, {
    alertType: alert?.type,
  });

  switch (state) {
    case "recovery":
      return [
        "✅ <b>Recovery</b>",
        "Health Factor recovered above your alert threshold",
      ];
    case "liquidation":
      return [
        "🚨 <b>Liquidation</b>",
        "Critical situation: your position may be liquidated",
      ];
    case "critical":
      return ["🚨 <b>Critical</b>", "Health Factor below your alert threshold"];
    case "warning":
    default:
      return ["⚠️ <b>Warning</b>", "Health Factor below your alert threshold"];
  }
}

function formatHfTelegramDisplay(value) {
  const hf = resolveHfNumericForDisplay(value);
  if (hf === null) return "--";
  if (hf === Infinity) return "♾️";
  return hf.toFixed(2);
}

function formatThresholdDisplay(threshold) {
  if (threshold === null || threshold === undefined || threshold === "") {
    return "n/a";
  }
  const n = Number(threshold);
  if (!Number.isFinite(n)) return String(threshold);
  return n.toFixed(2);
}

function formatHfChangeSegment(value, { bold = false } = {}) {
  const display = formatHfTelegramDisplay(value);
  if (display === "--") {
    return bold ? "<b>--</b>" : "--";
  }
  const icon = getHFIcon(value);
  const text = escapeTelegramHtml(display);
  if (bold) {
    return `${icon} <b>${text}</b>`.trim();
  }
  return `${icon} ${text}`.trim();
}

export function formatHealthFactorAlertForTelegram({
  alert,
  networkName = null,
}) {
  const currentDisplay = formatHfTelegramDisplay(alert?.current_hf);
  const firstLine =
    currentDisplay === "--"
      ? "<b>--</b>"
      : `${getHFIcon(alert?.current_hf)} <b>${escapeTelegramHtml(currentDisplay)}</b>`;

  const walletRaw = alert?.wallet_address;
  const wallet =
    walletRaw && typeof walletRaw === "string" && walletRaw.trim().length >= 10
      ? shortenAddress(walletRaw.trim())
      : "n/a";

  const lines = [firstLine, "", ...formatHealthFactorSeverityBlock(alert)];

  lines.push(
    "",
    `<blockquote expandable>💼: <b>${escapeTelegramHtml(wallet)}</b>`,
    "",
  );

  const isRecovery = alert?.type === "health_factor_recovery";
  const trendIcon = isRecovery ? "📈" : "📉";
  const networkLabel = escapeTelegramHtml(
    formatNetworkDisplayName(networkName),
  );
  lines.push(
    `${trendIcon} ${networkLabel}: ${formatHfChangeSegment(alert?.previous_hf)} → ${formatHfChangeSegment(alert?.current_hf, { bold: true })}`,
    `🎯 Alert threshold: ${escapeTelegramHtml(formatThresholdDisplay(alert?.payload?.threshold_hf))}</blockquote>`,
  );

  return lines.join("\n");
}

export function formatAlertForTelegram({ alert, networkName = null }) {
  if (HEALTH_FACTOR_ALERT_TYPES.has(alert?.type)) {
    return formatHealthFactorAlertForTelegram({ alert, networkName });
  }

  const threshold =
    alert?.payload?.threshold_hf != null
      ? formatHfValue(alert.payload.threshold_hf)
      : "n/a";

  const wallet =
    alert?.wallet_address != null
      ? shortenAddress(alert.wallet_address)
      : "n/a";

  const network = formatNetworkDisplayName(networkName);
  const header = severityLabel(alert?.severity);
  const title = alert?.title ?? "Health Factor Alert";

  return [
    `<strong>${header}</strong>`,
    `<u>${title}</u>`,
    `<tg-spoiler>💼 <code>${wallet}</code>`,
    "",
    `🌐 <code>${network}</code> <b>${formatHfValue(alert?.previous_hf)}</b>`,
    `🎯 Alert threshold: <b>${threshold}</b></tg-spoiler>`,
  ].join("\n");
}
