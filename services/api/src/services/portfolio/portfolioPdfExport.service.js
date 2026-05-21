import PDFDocument from "pdfkit";
import {
  formatAmount,
  formatDateTime,
  formatHealthFactor,
  formatPercentage,
  formatPriceDisplay,
  formatUsd,
  formatValueDisplay,
  getHealthFactorLabel,
  shortAddress,
} from "./portfolioPdfFormat.js";

const PAGE_MARGIN = 50;
const PAGE_BOTTOM = 792 - PAGE_MARGIN;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;
const BAR_MAX_WIDTH = 180;
const BAR_HEIGHT = 10;

const COLORS = {
  text: "#111827",
  muted: "#6B7280",
  line: "#E5E7EB",
  barTrack: "#E5E7EB",
  assets: "#2563EB",
  debts: "#DC2626",
  protocols: "#7C3AED",
  networks: "#059669",
};

function compareGroup(a, b) {
  const byProtocol = String(a.protocolName ?? a.protocol).localeCompare(
    String(b.protocolName ?? b.protocol),
  );
  if (byProtocol !== 0) return byProtocol;
  const byNetwork = String(a.networkName ?? a.network ?? "").localeCompare(
    String(b.networkName ?? b.network ?? ""),
  );
  if (byNetwork !== 0) return byNetwork;
  return String(a.walletLabel ?? a.walletAddress ?? "").localeCompare(
    String(b.walletLabel ?? b.walletAddress ?? ""),
  );
}

function nestedWalletIdentity(nested) {
  return {
    walletId: nested?.walletId != null ? String(nested.walletId) : null,
    walletAddress: String(
      nested?.walletAddress ?? nested?.address ?? "",
    ).toLowerCase(),
    walletLabel: nested?.walletLabel ?? nested?.label ?? null,
  };
}

export function findPositionHealth(positionsHealth, group) {
  const rows = Array.isArray(positionsHealth) ? positionsHealth : [];
  const walletId = group.walletId != null ? String(group.walletId) : null;
  const walletAddress = group.walletAddress
    ? String(group.walletAddress).toLowerCase()
    : null;

  return (
    rows.find(
      (row) =>
        row.protocol === group.protocol &&
        String(row.networkId) === String(group.networkId) &&
        walletId != null &&
        String(row.walletId) === walletId,
    ) ??
    rows.find(
      (row) =>
        row.protocol === group.protocol &&
        String(row.networkId) === String(group.networkId) &&
        walletAddress &&
        String(row.walletAddress).toLowerCase() === walletAddress,
    ) ??
    null
  );
}

export function buildDefiPositionGroups(portfolio) {
  const groups = new Map();

  const ensureGroup = (position, nested) => {
    const { walletId, walletAddress, walletLabel } = nestedWalletIdentity(nested);
    const key = `${position.protocol}:${position.networkId}:${walletId ?? walletAddress}`;
    if (!groups.has(key)) {
      groups.set(key, {
        protocol: position.protocol,
        protocolName: position.protocolName ?? position.protocol,
        networkId: position.networkId,
        network: position.network ?? null,
        networkName: position.networkName ?? null,
        walletId,
        walletAddress,
        walletLabel,
        supplied: [],
        borrowed: [],
        health: null,
      });
    }
    return groups.get(key);
  };

  for (const position of portfolio?.protocolPositions?.supplied ?? []) {
    for (const nested of position.wallets ?? []) {
      ensureGroup(position, nested).supplied.push({ position, nested });
    }
  }

  for (const position of portfolio?.protocolPositions?.borrowed ?? []) {
    for (const nested of position.wallets ?? []) {
      ensureGroup(position, nested).borrowed.push({ position, nested });
    }
  }

  const positionsHealth = portfolio?.defiRisk?.positionsHealth ?? [];
  for (const group of groups.values()) {
    group.health = findPositionHealth(positionsHealth, group);
  }

  return [...groups.values()].sort(compareGroup);
}

function parsePercentage(value) {
  if (value === null || value === undefined || value === "") return 0;
  const parsed = Number(String(value).replace("%", ""));
  return Number.isFinite(parsed) ? parsed : 0;
}

function createPdfContext(doc) {
  return {
    doc,
    ensureSpace(height) {
      if (doc.y + height > PAGE_BOTTOM) {
        doc.addPage();
      }
    },
    sectionTitle(title) {
      this.ensureSpace(28);
      doc
        .fillColor(COLORS.text)
        .font("Helvetica-Bold")
        .fontSize(14)
        .text(title, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
      doc.moveDown(0.4);
      doc
        .strokeColor(COLORS.line)
        .moveTo(PAGE_MARGIN, doc.y)
        .lineTo(PAGE_MARGIN + CONTENT_WIDTH, doc.y)
        .stroke();
      doc.moveDown(0.6);
    },
    paragraph(text, options = {}) {
      this.ensureSpace(16);
      doc
        .fillColor(options.color ?? COLORS.text)
        .font(options.bold ? "Helvetica-Bold" : "Helvetica")
        .fontSize(options.size ?? 10)
        .text(text, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
      doc.moveDown(options.spacing ?? 0.4);
    },
    keyValueRows(rows) {
      for (const [label, value] of rows) {
        this.ensureSpace(16);
        const y = doc.y;
        doc
          .fillColor(COLORS.muted)
          .font("Helvetica")
          .fontSize(10)
          .text(label, PAGE_MARGIN, y, { width: 180 });
        doc
          .fillColor(COLORS.text)
          .font("Helvetica-Bold")
          .fontSize(10)
          .text(String(value), PAGE_MARGIN + 190, y, { width: CONTENT_WIDTH - 190 });
        doc.moveDown(0.5);
      }
      doc.moveDown(0.3);
    },
    table(headers, rows, columnWidths) {
      const rowHeight = 18;
      const drawHeader = () => {
        this.ensureSpace(rowHeight + 4);
        let x = PAGE_MARGIN;
        const y = doc.y;
        headers.forEach((header, index) => {
          doc
            .fillColor(COLORS.muted)
            .font("Helvetica-Bold")
            .fontSize(9)
            .text(header, x + 2, y, { width: columnWidths[index] - 4 });
          x += columnWidths[index];
        });
        doc.y = y + rowHeight;
        doc
          .strokeColor(COLORS.line)
          .moveTo(PAGE_MARGIN, doc.y - 4)
          .lineTo(PAGE_MARGIN + CONTENT_WIDTH, doc.y - 4)
          .stroke();
      };

      drawHeader();

      for (const row of rows) {
        if (doc.y + rowHeight > PAGE_BOTTOM) {
          doc.addPage();
          drawHeader();
        }
        let x = PAGE_MARGIN;
        const y = doc.y;
        row.forEach((cell, index) => {
          doc
            .fillColor(COLORS.text)
            .font("Helvetica")
            .fontSize(9)
            .text(String(cell ?? "—"), x + 2, y, {
              width: columnWidths[index] - 4,
              ellipsis: true,
            });
          x += columnWidths[index];
        });
        doc.y = y + rowHeight;
      }
      doc.moveDown(0.6);
    },
    allocationSection(title, items, barColor, emptyMessage) {
      this.sectionTitle(title);
      if (!items?.length) {
        this.paragraph(emptyMessage, { color: COLORS.muted });
        return;
      }
      for (const item of items) {
        this.ensureSpace(24);
        const y = doc.y;
        const label = item.label ?? item.key ?? "—";
        const pct = formatPercentage(item.percentage);
        const value = formatUsd(item.valueUsd);
        doc
          .fillColor(COLORS.text)
          .font("Helvetica-Bold")
          .fontSize(10)
          .text(label, PAGE_MARGIN, y, { width: 120 });
        doc
          .font("Helvetica")
          .fontSize(10)
          .text(pct, PAGE_MARGIN + 125, y, { width: 55, align: "right" });
        doc.text(value, PAGE_MARGIN + 185, y, { width: 80, align: "right" });

        const barX = PAGE_MARGIN + 275;
        const barY = y + 1;
        const pctValue = parsePercentage(item.percentage);
        const fillWidth = Math.max(2, (pctValue / 100) * BAR_MAX_WIDTH);
        doc
          .fillColor(COLORS.barTrack)
          .rect(barX, barY, BAR_MAX_WIDTH, BAR_HEIGHT)
          .fill();
        doc.fillColor(barColor).rect(barX, barY, fillWidth, BAR_HEIGHT).fill();
        doc.y = y + 18;
      }
      doc.moveDown(0.4);
    },
  };
}

function renderHeader(ctx, portfolio, generatedAt) {
  const { doc } = ctx;
  doc
    .fillColor(COLORS.text)
    .font("Helvetica-Bold")
    .fontSize(20)
    .text("CryPrice Portfolio Report", PAGE_MARGIN, PAGE_MARGIN, {
      width: CONTENT_WIDTH,
    });
  doc
    .font("Helvetica")
    .fontSize(10)
    .fillColor(COLORS.muted)
    .text(`Generated at: ${formatDateTime(generatedAt)}`, PAGE_MARGIN, doc.y + 4);

  const walletsCount = portfolio?.summary?.walletsCount ?? portfolio?.wallets?.length ?? 0;
  doc.text(`Wallets: ${walletsCount}`, PAGE_MARGIN, doc.y + 2);
  doc.moveDown(1.2);
}

function renderSummary(ctx, portfolio) {
  const summary = portfolio?.summary ?? {};
  const health = portfolio?.defiRisk?.healthFactor ?? {};
  ctx.sectionTitle("Summary");
  ctx.keyValueRows([
    ["Net value", formatUsd(summary.netValueUsd ?? portfolio?.totals?.netValueUsd)],
    ["Wallet value", formatUsd(summary.walletValueUsd ?? portfolio?.totals?.walletValueUsd)],
    ["Supplied value", formatUsd(summary.suppliedValueUsd ?? portfolio?.totals?.suppliedValueUsd)],
    ["Borrowed value", formatUsd(summary.borrowedValueUsd ?? portfolio?.totals?.borrowedValueUsd)],
    ["Gross value", formatUsd(summary.grossValueUsd ?? portfolio?.totals?.grossValueUsd)],
    [
      "Health Factor",
      `${formatHealthFactor(summary.healthFactor ?? health.value)} - ${getHealthFactorLabel(
        summary.healthFactorStatus ?? health.status,
        summary.healthFactorStatusLabel ?? health.statusLabel,
      )}`,
    ],
    ["Portfolio updated at", formatDateTime(summary.updatedAt)],
  ]);
}

function renderAllocation(ctx, portfolio) {
  const allocation = portfolio?.allocation;
  ctx.sectionTitle("Allocation");
  if (!allocation) {
    ctx.paragraph("No allocation data.", { color: COLORS.muted });
    return;
  }

  ctx.allocationSection(
    "Assets allocation",
    allocation.assets,
    COLORS.assets,
    "No asset allocation data.",
  );

  if (allocation.debts?.length) {
    ctx.allocationSection(
      "Debts allocation",
      allocation.debts,
      COLORS.debts,
      "No debt positions.",
    );
  } else {
    ctx.paragraph("No debt positions.", { color: COLORS.muted });
  }

  ctx.allocationSection(
    "Protocol allocation",
    allocation.protocols,
    COLORS.protocols,
    "No protocol allocation data.",
  );
  ctx.allocationSection(
    "Network allocation",
    allocation.networks,
    COLORS.networks,
    "No network allocation data.",
  );
}

function renderWallets(ctx, portfolio) {
  ctx.sectionTitle("Wallets");
  const wallets = portfolio?.wallets ?? [];
  if (!wallets.length) {
    ctx.paragraph("No registered wallets.", { color: COLORS.muted });
    return;
  }

  ctx.table(
    ["Label", "Address", "Wallet value", "Supplied", "Borrowed", "Net", "HF"],
    wallets.map((wallet) => [
      wallet.walletLabel ?? shortAddress(wallet.walletAddress),
      shortAddress(wallet.walletAddress),
      formatUsd(wallet.walletValueUsd),
      formatUsd(wallet.suppliedValueUsd),
      formatUsd(wallet.borrowedValueUsd),
      formatUsd(wallet.netValueUsd),
      formatHealthFactor(wallet.healthFactor),
    ]),
    [70, 70, 60, 60, 60, 60, 45],
  );
}

function renderWalletHoldings(ctx, portfolio) {
  ctx.sectionTitle("Wallet Holdings");
  const holdings = portfolio?.walletHoldings ?? [];
  if (!holdings.length) {
    ctx.paragraph("No wallet holdings.", { color: COLORS.muted });
    return;
  }

  ctx.table(
    ["Asset", "Network", "Balance", "Current price", "USD value", "Price status"],
    holdings.map((row) => [
      row.assetSymbol ?? row.symbol,
      row.networkName ?? row.network,
      formatAmount(row.amount),
      formatPriceDisplay(row.priceUsd, row.priceStatus),
      formatValueDisplay(row.valueUsd, row.priceStatus),
      row.priceStatus ?? "—",
    ]),
    [70, 70, 70, 80, 70, 60],
  );
}

function renderDefiPositions(ctx, portfolio) {
  ctx.sectionTitle("DeFi Positions");
  const groups = buildDefiPositionGroups(portfolio);
  if (!groups.length) {
    ctx.paragraph("No DeFi positions.", { color: COLORS.muted });
    return;
  }

  for (const group of groups) {
    ctx.ensureSpace(80);
    const header = `${group.protocolName} / ${group.networkName ?? group.network} / ${
      group.walletLabel ?? shortAddress(group.walletAddress)
    }`;
    ctx.paragraph(header, { bold: true, size: 11 });

    const health = group.health;
    if (health) {
      ctx.paragraph(
        `Health Factor: ${formatHealthFactor(health.healthFactor ?? health.value)} - ${getHealthFactorLabel(
          health.status,
          health.statusLabel,
        )}`,
        { color: COLORS.muted },
      );
      ctx.paragraph(`Updated: ${formatDateTime(health.updatedAt)}`, {
        color: COLORS.muted,
        spacing: 0.2,
      });
    } else {
      ctx.paragraph("Health Factor: —", { color: COLORS.muted });
    }

    if (group.supplied.length) {
      ctx.paragraph("Supplied", { bold: true, size: 10, spacing: 0.2 });
      ctx.table(
        ["Asset", "Balance", "Current price", "USD value"],
        group.supplied.map(({ position, nested }) => [
          position.underlyingSymbol,
          formatAmount(nested.amount ?? nested.balance),
          formatPriceDisplay(position.priceUsd, position.priceStatus),
          formatValueDisplay(nested.valueUsd, position.priceStatus),
        ]),
        [90, 90, 110, 90],
      );
    }

    if (group.borrowed.length) {
      ctx.paragraph("Borrowed", { bold: true, size: 10, spacing: 0.2 });
      ctx.table(
        ["Asset", "Balance", "Current price", "USD value", "Debt type"],
        group.borrowed.map(({ position, nested }) => [
          position.underlyingSymbol,
          formatAmount(nested.amount ?? nested.balance),
          formatPriceDisplay(position.priceUsd, position.priceStatus),
          formatValueDisplay(nested.valueUsd, position.priceStatus),
          position.debtType ?? "—",
        ]),
        [80, 80, 90, 80, 70],
      );
    }

    docMoveDown(ctx, 0.4);
  }
}

function docMoveDown(ctx, lines = 1) {
  ctx.doc.moveDown(lines);
}

function renderFooter(ctx) {
  ctx.sectionTitle("Notes");
  ctx.paragraph("This report is generated from CryPrice portfolio data.", {
    color: COLORS.muted,
  });
  ctx.paragraph("Borrowed values are shown as positive liabilities.", {
    color: COLORS.muted,
  });
  ctx.paragraph(
    "Net value = wallet value + supplied value - borrowed value.",
    { color: COLORS.muted },
  );
  ctx.paragraph(
    "Prices and Health Factor are based on last available backend data.",
    { color: COLORS.muted },
  );
}

export function renderPortfolioPdfDocument(doc, portfolio, options = {}) {
  const generatedAt = options.generatedAt ?? new Date();
  const ctx = createPdfContext(doc);
  renderHeader(ctx, portfolio, generatedAt);
  renderSummary(ctx, portfolio);
  renderAllocation(ctx, portfolio);
  renderWallets(ctx, portfolio);
  renderWalletHoldings(ctx, portfolio);
  renderDefiPositions(ctx, portfolio);
  renderFooter(ctx);
}

export function generatePortfolioPdf(portfolio, options = {}) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: "A4",
      margin: PAGE_MARGIN,
      info: {
        Title: "CryPrice Portfolio Report",
        Author: "CryPrice",
      },
    });
    const chunks = [];

    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    try {
      renderPortfolioPdfDocument(doc, portfolio, options);
      doc.end();
    } catch (error) {
      reject(error);
    }
  });
}
