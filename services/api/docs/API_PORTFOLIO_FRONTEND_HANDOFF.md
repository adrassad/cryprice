# Portfolio API — Frontend Handoff

## Portfolio API Overview

`GET /portfolio` is the main CryPrice portfolio dashboard endpoint. It returns the authenticated user's full portfolio in one response: wallet holdings, DeFi positions, USD rollups, wallet selector, protocol cards, and stored Health Factor data.

Designed for **local frontend filtering** by protocol and wallet — no extra API calls when switching filters. Query params for `protocol` / `walletId` are **not implemented** yet.

Health Factor is **not** calculated live on this request. Values come from stored DB history. Global HF is the **lowest finite** (riskiest) HF in scope.

---

## Endpoint

| | |
|---|---|
| **Method** | `GET` |
| **Path** | `/portfolio` |
| **Auth** | `Authorization: Bearer <ACCESS_TOKEN>` |

**Optional query:** `includeWallets` — `true` (default/omit) or `false`. When `false`, nested `wallets[]` on holdings/positions are empty; per-wallet row filtering needs default `includeWallets=true`.

```bash
curl -H "Authorization: Bearer <ACCESS_TOKEN>" <API_BASE_URL>/portfolio
```

### PDF export (backend)

| | |
|---|---|
| **Method** | `GET` |
| **Path** | `/portfolio/export/pdf` |
| **Auth** | `Authorization: Bearer <ACCESS_TOKEN>` |
| **Response** | `application/pdf` attachment |

Uses the same aggregation as `GET /portfolio` (summary, allocation, wallets, holdings, DeFi positions). Not a frontend screenshot. See `docs/API_PORTFOLIO.md` for details.

---

## High-Level Response Shape

```json
{
  "summary": {},
  "networks": [],
  "walletHoldings": [],
  "protocolPositions": { "supplied": [], "borrowed": [] },
  "defiRisk": { "healthFactor": {}, "positionsHealth": [] },
  "totals": {},
  "wallets": [],
  "protocolSummaries": [],
  "allocation": {
    "assets": [],
    "debts": [],
    "protocols": [],
    "networks": [],
    "wallets": []
  }
}
```

**New dashboard — prefer:** `walletHoldings`, `protocolPositions`, `wallets`, `protocolSummaries`, `defiRisk`, `allocation`.  
**Legacy:** `networks[]` (network → assets → wallets).

**Charts — prefer:** `allocation` (backend-built series; do not recalculate pie slices on the client).

---

## summary

| Field | Meaning |
|-------|---------|
| `totalValueUsd` | Legacy: wallet holdings only (= `walletValueUsd`) |
| `walletsCount`, `assetsCount`, `networksCount` | Counts |
| `updatedAt` | Latest balance/price sync (ISO) |
| `walletValueUsd` | Wallet holdings total |
| `suppliedValueUsd` | Supplied DeFi total |
| `borrowedValueUsd` | Borrowed total (**positive**) |
| `grossValueUsd` | `walletValueUsd + suppliedValueUsd` |
| `netValueUsd` | `walletValueUsd + suppliedValueUsd - borrowedValueUsd` |
| `healthFactor`, `healthFactorStatus`, `healthFactorStatusLabel` | Global riskiest HF |

```json
{
  "totalValueUsd": "250.03",
  "walletsCount": 2,
  "assetsCount": 3,
  "networksCount": 2,
  "updatedAt": "2026-05-20T08:00:00.000Z",
  "walletValueUsd": "250.03",
  "suppliedValueUsd": "1000.00",
  "borrowedValueUsd": "200.00",
  "grossValueUsd": "1250.03",
  "netValueUsd": "1050.03",
  "healthFactor": "1.45",
  "healthFactorStatus": "at_risk",
  "healthFactorStatusLabel": "At risk"
}
```

Null `valueUsd` rows are excluded from USD totals.

---

## totals

Mirror of extended USD fields. Use `totals.netValueUsd` or `summary.netValueUsd` as main portfolio value — do not recalculate unless necessary.

```json
{
  "walletValueUsd": "250.03",
  "suppliedValueUsd": "1000.00",
  "borrowedValueUsd": "200.00",
  "grossValueUsd": "1250.03",
  "netValueUsd": "1050.03"
}
```

---

## wallets

Wallet selector (level 2). One entry per **registered** wallet (including zero-balance).

| Field | Meaning |
|-------|---------|
| `walletId`, `walletAddress`, `walletLabel` | Identity (`walletLabel` null → shorten address) |
| `walletValueUsd` | Wallet holdings for this wallet |
| `suppliedValueUsd`, `borrowedValueUsd` | DeFi sums (borrowed positive) |
| `grossValueUsd` | `walletValueUsd + suppliedValueUsd` |
| `netValueUsd` | `grossValueUsd - borrowedValueUsd` |
| `healthFactor`, `healthFactorStatus`, `healthFactorStatusLabel` | Lowest finite HF for wallet |

```json
{
  "walletId": "1",
  "walletAddress": "0x1111...1111",
  "walletLabel": "Main wallet",
  "walletValueUsd": "100.01",
  "suppliedValueUsd": "4000.00",
  "borrowedValueUsd": "1000.00",
  "grossValueUsd": "4100.01",
  "netValueUsd": "3100.01",
  "healthFactor": "1.45",
  "healthFactorStatus": "at_risk",
  "healthFactorStatusLabel": "At risk"
}
```

---

## protocolSummaries

Protocol cards (level 1). Always includes pseudo-protocol `wallet` plus DeFi protocols in positions (e.g. `aave_v3`).

| Field | Meaning |
|-------|---------|
| `protocol`, `protocolName`, `category` | `wallet` / `lending` / `unknown` |
| `walletValueUsd` … `netValueUsd` | Same rollup semantics as `wallets` |
| `totalValueUsd` | Wallet card: `walletValueUsd`; DeFi: `suppliedValueUsd` |
| `healthFactor`, `healthFactorStatus`, `healthFactorStatusLabel` | Scoped HF (`none` for wallet) |
| `networks[]` | Per-network `netValueUsd` + HF (DeFi only) |

DB `aave` → API `aave_v3`.

---

## walletHoldings

Normal wallet assets — use for **Wallet** protocol filter. One row per `networkId + assetId`.

| Field | Meaning |
|-------|---------|
| `kind` | `"wallet_holding"` |
| `networkId`, `network`, `networkName`, `chainId` | Network |
| `assetId`, `assetSymbol`, `assetAddress`, `symbol`, `address` | Asset |
| `amount`, `balanceRaw`, `decimals` | Balance |
| `priceUsd`, `valueUsd`, `priceStatus` | Price (`ok` / `missing` / `stale`) |
| `wallets[]` | Per-wallet breakdown |

**Nested `wallets[]`:** `walletId`, `address`/`label`, aliases `walletAddress`/`walletLabel`, **`balance`** (not `amount`), `valueUsd`, `syncedAt`, `blockNumber`.

No top-level `walletId` on rows — filter via nested `wallets[]`.

---

## protocolPositions

| | |
|---|---|
| `supplied` | Collateral / deposits |
| `borrowed` | Debt (`debtType`: `stable` \| `variable`) |

Shared fields: `kind`, `protocol`, `protocolName`, `networkId`, `network`, `networkName`, `chainId`, `positionSide`, `tokenRole`, `underlyingSymbol`, `underlyingAddress`, `tokenSymbol`, `tokenAddress`, `amount`, `balanceRaw`, `decimals`, `priceUsd`, `valueUsd`, `priceStatus`, `wallets[]`.

- `priceUsd` = **underlying** asset price (e.g. WETH for aWETH).
- Borrowed `valueUsd` is **positive** — do not negate in UI.
- Nested `wallets[]` use `amount` + `walletAddress` / `walletLabel` aliases.

---

## defiRisk

### `defiRisk.healthFactor` (global)

| Field | Meaning |
|-------|---------|
| `value` | HF string, `"Infinity"`, or `null` |
| `status`, `statusLabel` | Risk band (not `healthFactorStatus`) |
| `protocol`, `protocolName` | Source of selected HF |
| `updatedAt`, `stale` | `stale` is informational only |

Matches `summary.healthFactor` / `healthFactorStatus`.

### `defiRisk.positionsHealth[]`

Per wallet + network + protocol. Match by `walletId` or `walletAddress` + `networkId` + `protocol`.

Fields: `walletId`, `walletAddress`, `walletLabel`, `protocol`, `protocolName`, `networkId`, `network`, `networkName`, `healthFactor`, `value` (duplicate of `healthFactor`), `status`, `statusLabel`, `threshold`, `updatedAt`, `stale`.

---

## priceStatus

| Status | UI |
|--------|-----|
| `ok` | Show price + value |
| `missing` | `priceUsd`/`valueUsd` null → **"Price unavailable"**, not `$0` |
| `stale` | Price >1h old — show value + stale indicator |

Real zero: `priceUsd: "0"`, `valueUsd: "0.00"`, `priceStatus: "ok"`.

---

## Health Factor statuses

| Status | Meaning |
|--------|---------|
| `none` | Wallet pseudo-protocol |
| `missing` | No stored HF |
| `no_debt` | HF is Infinity-like |
| `safe` | HF > 2 |
| `watch` | HF ≤ 2 |
| `warning` | HF ≤ 1.5 |
| `at_risk` | HF ≤ user threshold (default 1.2) |
| `liquidation_risk` | HF ≤ 1 |

Selection: **lowest finite** in scope → else `no_debt` → else `missing`.  
`stale` on rows is a boolean, not a `status` value.

---

## Frontend filtering (client-side)

**Level 1 — `selectedProtocol`:** `all` | `wallet` | `aave_v3` | …

| Protocol | Show |
|----------|------|
| `all` | `walletHoldings` + all `protocolPositions` |
| `wallet` | `walletHoldings` only |
| `aave_v3` | `protocolPositions` where `protocol === "aave_v3"` |

Cards: `protocolSummaries`. HF badges: `protocolSummaries` / `defiRisk.positionsHealth`.

**Level 2 — `selectedWalletId`:** `all` | `walletId`

| Wallet | Show |
|--------|------|
| `all` | Row-level `amount` / `valueUsd` |
| specific | Filter nested `wallets[]`; use nested `balance` (holdings) or `amount` (protocol) |

Selector: top-level `wallets[]`.

---

## allocation

Chart-ready series for the full portfolio (no wallet/protocol query scoping yet).

```json
{
  "allocation": {
    "assets": [],
    "debts": [],
    "protocols": [],
    "networks": [],
    "wallets": []
  }
}
```

### `allocation.assets`

Positive exposure only: **wallet holdings + supplied DeFi**.

| Rule | Detail |
|------|--------|
| Includes | `walletHoldings[]`, `protocolPositions.supplied[]` |
| Excludes | `protocolPositions.borrowed[]` (never as negative assets) |
| Label | `assetSymbol` / `symbol` (wallet); `underlyingSymbol` (supplied — not `tokenSymbol`) |
| `valueUsd` / `percentage` | Strings, 2 decimals; null/missing/zero omitted |
| Denominator | Sum of positive asset `valueUsd` only |

Item fields: `key`, `label`, `valueUsd`, `percentage`, `source` (`wallet` \| `supplied`), `protocol`, `protocolName`, `network`, `networkName`, `assetSymbol`, `priceUsd`, `priceStatus`.

### `allocation.debts`

Debt-only series from `protocolPositions.borrowed[]`.

| Rule | Detail |
|------|--------|
| `valueUsd` | Positive (liability size, not negated) |
| Label | `underlyingSymbol` |
| Extra | `debtType` when present (`stable` \| `variable`) |
| Denominator | Sum of positive borrowed `valueUsd` |

**Do not** put debt rows in `allocation.assets`.

### `allocation.protocols`

From `protocolSummaries[]`. Chart value = **`netValueUsd`** (protocol value after debt). Tooltip fields: `walletValueUsd`, `suppliedValueUsd`, `borrowedValueUsd`, `grossValueUsd`, `netValueUsd`, `category`. Omits protocols with `netValueUsd <= 0`.

### `allocation.networks`

Per-network: `wallet holdings + supplied - borrowed`. Chart value = positive **`netValueUsd`** only. Omits networks with net ≤ 0.

### Other grouping

Applied per series (`assets`, `debts`, `protocols`, `networks`):

- Default `maxItems = 8`, `minPercentage = 1.00`
- Sort by `valueUsd` desc; keep largest until cap/threshold; rest → `Other`
- Other item: `key: "other"`, `label: "Other"`, `childrenCount`, summed `valueUsd` / recomputed `percentage`

### `allocation.wallets[]`

Per-wallet chart series (same four sections nested per wallet).

| Field | Meaning |
|-------|---------|
| `walletId`, `walletAddress`, `walletLabel` | From top-level `wallets[]` |
| `assets` | Holdings + supplied for **this wallet only** (nested `wallets[]` values) |
| `debts` | Borrowed for **this wallet only** |
| `protocols` | Wallet pseudo-protocol + per-protocol net from nested rows |
| `networks` | Per-network net for **this wallet only** |

**Choosing series (do not recalculate on client):**

| Wallet filter | Use |
|---------------|-----|
| All wallets | `allocation.assets`, `.debts`, `.protocols`, `.networks` |
| Specific `walletId` | `allocation.wallets[]` entry where `walletId` matches → `.assets`, `.debts`, `.protocols`, `.networks` |

Protocol filter still applies to **tables** (`walletHoldings` / `protocolPositions`); allocation charts switch by wallet scope only.

Wallet-scoped rows use nested `valueUsd` (not parent aggregate). Same Other grouping (`maxItems=8`, `minPercentage=1%`) per nested series.

### Frontend

- Render slices from selected `allocation.*` series as-is (format tooltips only).
- Use `protocolPositions` / filters for tables; use `allocation` for pies/donuts.
- Two debt/asset charts: `assets` and `debts` are separate series (global or per-wallet).
- Do **not** recompute pie percentages or net values in the client.

---

## Display rules

**Every row:** Asset · Balance · Current Price (`priceUsd`) · USD Value (`valueUsd`).

**Borrowed:** liabilities in `protocolPositions.borrowed` only; positive `valueUsd`; `netValueUsd` already subtracts debt.

**Numbers:** all money/balances are **strings** — use decimal-safe math, not `parseFloat`.

---

## Verification

```bash
curl -s -H "Authorization: Bearer <TOKEN>" <API_BASE_URL>/portfolio | jq '.allocation'
curl -s -H "Authorization: Bearer <TOKEN>" <API_BASE_URL>/portfolio | jq '.allocation.wallets'
curl -s -H "Authorization: Bearer <TOKEN>" <API_BASE_URL>/portfolio | jq '{
  summary, totals, wallets, protocolSummaries,
  walletHoldings, protocolPositions, defiRisk, allocation
}'
```

---

## Edge cases (quick reference)

| Case | Notes |
|------|-------|
| No wallets | `wallets: []`; `protocolSummaries` still has `wallet` with zeros |
| Zero-balance wallet | In `wallets[]` with `"0.00"` totals |
| Holdings only | Empty `protocolPositions`; no Aave card except wallet |
| Missing price | Excluded from totals; show unavailable |
| Missing HF | `null` + `missing` |
| `no_debt` | `healthFactor: "Infinity"` |
| `liquidation_risk` | HF ≤ 1 |

---

## Related docs

- `docs/API_PORTFOLIO.md` — errors, `includeWallets`, legacy `networks` detail
