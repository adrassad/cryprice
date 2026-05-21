// src/bot/utils/hfFormatter.js

function normalizeHF(value) {
  const num = Number(value);
  if (!Number.isFinite(num) || num === 0) return Infinity;
  return num;
}

function getHFIcon(value) {
  if (value === Infinity) return "♾️";
  if (value > 2) return "💚";
  if (value > 1.5) return "💛";
  if (value > 1.2) return "🧡";
  if (value > 1) return "❤️";
  return "💔";
}

function formatValue(value, digits = 2) {
  if (value === Infinity) return "∞";
  return value.toFixed(digits);
}

function shortenAddress(address) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

export function formatHealthFactorOverview(walletMap) {
  /*
    walletMap: Map<string, Map<string, number>>
  */

  let hasCritical = false;
  const walletBlocks = [];

  for (const [wallet, networksMap] of walletMap.entries()) {
    const networks = [];

    for (const [network, rawHF] of networksMap.entries()) {
      const hf = normalizeHF(rawHF);

      if (hf < 1.2) {
        hasCritical = true;
      }

      networks.push({
        name: network,
        hf,
        icon: getHFIcon(hf),
      });
    }

    // сортировка по риску
    networks.sort((a, b) => a.hf - b.hf);

    const lines = networks.map((n) => {
      const displayName = n.name.charAt(0) + n.name.slice(1).toLowerCase();

      return `${displayName.padEnd(12)} ${n.icon}  ${formatValue(n.hf)}`;
    });

    if (lines.length > 0) {
      walletBlocks.push(
        `💼 <b>${shortenAddress(wallet)}</b>\n\n<pre>\n${lines.join(
          "\n",
        )}\n</pre>`,
      );
    }
  }

  const header = hasCritical
    ? "🚨 <b>Health Factor Alert</b>"
    : "📊 <b>Health Factor Overview</b>";

  return `${header}\n\n${walletBlocks.join("\n\n")}`;
}
