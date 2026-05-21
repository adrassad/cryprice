# Portfolio API

## Endpoint

`GET /portfolio`

Returns a frontend-ready portfolio aggregated across all wallets owned by the authenticated user. The response supports a DeBank-like portfolio dashboard with **local two-level filtering** (protocol, then wallet) without query parameters.

## Authentication

Requires an access token:

```http
Authorization: Bearer <accessToken>
```

The backend uses the authenticated internal user id from the access token. Clients must not send a user id.

## Query Params

`includeWallets`:

- `true` or omitted: include per-asset wallet breakdowns in `networks`, `walletHoldings`, and `protocolPositions`.
- `false`: return the same response shape, but nested `wallets: []` on those sections.

**Not supported yet:** `protocol`, `walletId` (frontend filters the full response locally).

## Response Overview

| Section | Purpose |
|---------|---------|
| `summary` | Global counts, USD totals, global health factor |
| `networks` | Legacy wallet-token aggregation by network + asset |
| `walletHoldings` | Flat wallet token rows with price per row |
| `protocolPositions` | DeFi supplied / borrowed rows with underlying price |
| `defiRisk` | Stored health factor summary + per-position rows |
| `wallets` | Wallet selector chips with per-wallet USD + HF |
| `protocolSummaries` | Protocol cards (Wallet, Aave V3, …) with network breakdown |
| `totals` | USD rollup mirror |
| `allocation` | Chart-ready global + per-wallet `wallets[]` series (see handoff doc) |

Health factors are read from **stored** history only. `GET /portfolio` does **not** calculate live on-chain health factor.

## PDF Export

`GET /portfolio/export/pdf`

Generates a downloadable PDF report from the **same** aggregated portfolio data as `GET /portfolio` (via `getAggregatedUserPortfolio`). No separate portfolio calculation, no live RPC, no live Health Factor.

### Authentication

Same as `GET /portfolio`:

```http
Authorization: Bearer <accessToken>
```

The authenticated user's internal `users.id` is used. Client-supplied user ids are not accepted.

### Response

- `Content-Type: application/pdf`
- `Content-Disposition: attachment; filename="cryprice-portfolio-report-YYYY-MM-DD.pdf"`

### Report contents

1. Header — title, generated timestamp, wallet count  
2. Summary — net/wallet/supplied/borrowed/gross values, Health Factor, portfolio `updatedAt`  
3. Allocation — horizontal bar rows for assets, debts (if any), protocols, networks  
4. Wallets — per-wallet totals table  
5. Wallet holdings — asset rows with balance, current price, USD value, price status  
6. DeFi positions — grouped by protocol / network / wallet with supplied & borrowed tables and stored HF  
7. Notes — data source and calculation disclaimers  

Borrowed values are shown as **positive liabilities**. Debts are not merged into assets allocation.

### Example

```bash
curl -L \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -o cryprice-portfolio-report.pdf \
  https://api.cryprice.dev/portfolio/export/pdf
```

Empty portfolios still return a valid PDF with empty-state sections.

## Response Example (abbreviated)

```json
{
  "summary": {
    "totalValueUsd": "250.03",
    "walletsCount": 2,
    "assetsCount": 1,
    "networksCount": 1,
    "updatedAt": "2026-05-19T13:22:00.000Z",
    "walletValueUsd": "250.03",
    "suppliedValueUsd": "8378.67",
    "borrowedValueUsd": "4033.52",
    "grossValueUsd": "8628.70",
    "netValueUsd": "4595.18",
    "healthFactor": "1.15",
    "healthFactorStatus": "at_risk",
    "healthFactorStatusLabel": "At risk"
  },
  "networks": [],
  "walletHoldings": [],
  "protocolPositions": { "supplied": [], "borrowed": [] },
  "defiRisk": {
    "healthFactor": { "value": "1.15", "status": "at_risk", "statusLabel": "At risk" },
    "positionsHealth": []
  },
  "wallets": [
    {
      "walletId": "1",
      "walletAddress": "0x1111...",
      "walletLabel": "Main",
      "walletValueUsd": "100.01",
      "suppliedValueUsd": "5000.00",
      "borrowedValueUsd": "2000.00",
      "grossValueUsd": "5100.01",
      "netValueUsd": "3100.01",
      "healthFactor": "1.15",
      "healthFactorStatus": "at_risk",
      "healthFactorStatusLabel": "At risk"
    }
  ],
  "protocolSummaries": [
    {
      "protocol": "wallet",
      "protocolName": "Wallet",
      "category": "wallet",
      "walletValueUsd": "250.03",
      "suppliedValueUsd": "0.00",
      "borrowedValueUsd": "0.00",
      "grossValueUsd": "250.03",
      "netValueUsd": "250.03",
      "totalValueUsd": "250.03",
      "healthFactor": null,
      "healthFactorStatus": "none",
      "healthFactorStatusLabel": null,
      "networks": []
    },
    {
      "protocol": "aave_v3",
      "protocolName": "Aave V3",
      "category": "lending",
      "walletValueUsd": "0.00",
      "suppliedValueUsd": "8378.67",
      "borrowedValueUsd": "4033.52",
      "grossValueUsd": "8378.67",
      "netValueUsd": "4345.15",
      "totalValueUsd": "8378.67",
      "healthFactor": "1.15",
      "healthFactorStatus": "at_risk",
      "healthFactorStatusLabel": "At risk",
      "networks": [
        {
          "networkId": 1,
          "network": "ethereum",
          "networkName": "Ethereum",
          "netValueUsd": "4345.15",
          "healthFactor": "1.15",
          "healthFactorStatus": "at_risk",
          "healthFactorStatusLabel": "At risk"
        }
      ]
    }
  ],
  "totals": {
    "walletValueUsd": "250.03",
    "suppliedValueUsd": "8378.67",
    "borrowedValueUsd": "4033.52",
    "grossValueUsd": "8628.70",
    "netValueUsd": "4595.18"
  }
}
```

## `summary`

| Field | Meaning |
|-------|---------|
| `totalValueUsd` | Sum of wallet holdings only (legacy); same as `walletValueUsd` |
| `walletsCount` | Distinct wallets with portfolio rows |
| `assetsCount` | Distinct `networkId + assetId` wallet holding groups |
| `networksCount` | Networks with at least one wallet holding |
| `updatedAt` | Latest balance sync or price timestamp |
| `walletValueUsd` | Total wallet holdings USD |
| `suppliedValueUsd` | Total supplied protocol positions USD |
| `borrowedValueUsd` | Total borrowed protocol positions USD (positive display value) |
| `grossValueUsd` | `walletValueUsd + suppliedValueUsd` |
| `netValueUsd` | `grossValueUsd - borrowedValueUsd` |
| `healthFactor` | Lowest finite HF across all `positionsHealth`, else no-debt / missing |
| `healthFactorStatus` | Risk band for global HF |
| `healthFactorStatusLabel` | Human-readable global HF label |

## `networks` (legacy)

Unchanged shape: networks → assets → optional `wallets[]` breakdown.

Use for backward compatibility. New UI should prefer `walletHoldings` and `wallets` / `protocolSummaries` for dashboard layout.

## `walletHoldings`

Flat list of wallet token positions (one row per `networkId + assetId` aggregate).

Each row includes token price fields for the CryPrice UI:

| Field | Meaning |
|-------|---------|
| `symbol` / `assetSymbol` | Token symbol |
| `amount` | Formatted balance |
| `priceUsd` | Current on-chain price or `null` |
| `priceStatus` | `ok`, `missing`, or `stale` |
| `valueUsd` | `amount * priceUsd`, or `null` if price missing |
| `wallets[]` | Per-wallet breakdown when `includeWallets=true` |

Nested `wallets[]` entries keep legacy `address` and `label`, and add aliases `walletAddress` and `walletLabel`.

There is **no** top-level `walletId` on holding rows; filter by wallet using nested `wallets[]` or the top-level `wallets` selector array.

## `protocolPositions`

```json
{
  "supplied": [ /* ... */ ],
  "borrowed": [ /* ... */ ]
}
```

Each position row includes:

| Field | Meaning |
|-------|---------|
| `underlyingSymbol` | Underlying asset (e.g. WETH for aWETH supply) |
| `amount` | Position balance |
| `priceUsd` | Current price of the **underlying** (via `price_asset_id`) |
| `priceStatus` | `ok`, `missing`, or `stale` |
| `valueUsd` | USD value or `null` |
| `protocol` | API id (e.g. `aave_v3`) |
| `protocolName` | Display name (e.g. `Aave V3`) |
| `networkId`, `network`, `networkName` | Network context |
| `wallets[]` | Per-wallet amounts with `walletAddress` / `walletLabel` aliases |

Borrowed USD values are **positive** in all rollups.

## `defiRisk`

| Field | Meaning |
|-------|---------|
| `healthFactor` | Global riskiest (lowest finite) HF object |
| `positionsHealth[]` | One row per wallet + network + protocol from stored HF |

Each `positionsHealth` row includes:

- `walletId`, `walletAddress`, `walletLabel`
- `protocol`, `protocolName`, `networkId`, `network`, `networkName`
- `healthFactor`, `status`, `statusLabel`, `threshold`, `updatedAt`, `stale`
- Legacy duplicate: `value` (= `healthFactor`)

`stale` is informational (HF history may not update every poll); it does not override `status`.

## `wallets` (selector)

One entry per registered user wallet (including zero-balance wallets).

| Field | Meaning |
|-------|---------|
| `walletValueUsd` | Sum of nested wallet holding `valueUsd` for this wallet |
| `suppliedValueUsd` | Sum of supplied protocol `valueUsd` for this wallet |
| `borrowedValueUsd` | Sum of borrowed protocol `valueUsd` (positive) |
| `grossValueUsd` | `walletValueUsd + suppliedValueUsd` |
| `netValueUsd` | `grossValueUsd - borrowedValueUsd` |
| `healthFactor` | Lowest finite HF for this wallet from `positionsHealth` |
| `healthFactorStatus` | `missing` if no HF rows; `no_debt` if only Infinity; else risk band |

Use `walletLabel` for display; if `null`, shorten `walletAddress` on the frontend.

## `protocolSummaries` (protocol cards)

Always includes a pseudo-protocol for normal wallet holdings:

| Field | Wallet protocol | DeFi protocol (e.g. Aave V3) |
|-------|-----------------|------------------------------|
| `protocol` | `wallet` | `aave_v3`, … |
| `category` | `wallet` | `lending` (or `unknown`) |
| `walletValueUsd` | Total wallet holdings | `0.00` |
| `totalValueUsd` | Same as `walletValueUsd` | Same as `suppliedValueUsd` |
| `healthFactor` | `null` | Lowest finite HF for protocol |
| `healthFactorStatus` | `none` | From stored HF |
| `networks[]` | `[]` | Per-network `netValueUsd` and HF |

Protocol HF and network HF use the **lowest finite** stored value in that scope. No live HF calculation.

## `totals`

Duplicate of extended USD fields in `summary` for convenience.

## Price Status

Used consistently on `networks[].assets`, `walletHoldings`, and `protocolPositions`:

| Status | Condition |
|--------|-----------|
| `ok` | Price exists and `priceCalculatedAt` is within stale threshold (default 1 hour) |
| `missing` | No price; `priceUsd` and `valueUsd` are `null` |
| `stale` | Price exists but older than threshold; `priceUsd` and `valueUsd` still returned |

A real zero price is not missing: `priceUsd: "0"`, `valueUsd: "0.00"`, `priceStatus: "ok"`.

Null `valueUsd` rows are excluded from USD totals.

## Health Factor Statuses

| Status | Meaning |
|--------|---------|
| `none` | Wallet protocol summary only (no DeFi HF) |
| `missing` | No stored HF for scope |
| `no_debt` | Stored HF is Infinity (no borrow risk) |
| `liquidation_risk` | HF ≤ 1 |
| `at_risk` | HF ≤ user threshold (default 1.2) |
| `warning` | HF ≤ 1.5 |
| `watch` | HF ≤ 2 |
| `safe` | HF > 2 |

Global and scoped HF selection: **lowest finite** value in scope; if none, fall back to `no_debt`; if none at all, `missing`.

## Local Filtering (frontend)

Recommended filters (no backend query params):

1. **Level 1 — `selectedProtocol`:** `all` | `wallet` | `aave_v3` | …
   - `wallet` → show `walletHoldings` only
   - `aave_v3` → show `protocolPositions` where `protocol === "aave_v3"`
   - `all` → holdings + all protocol positions
   - Use `protocolSummaries` for card totals and HF badges

2. **Level 2 — `selectedWallet`:** `all` | `walletId`
   - `all` → use top-level `amount` / `valueUsd` on rows
   - specific wallet → filter nested `wallets[]` to matching `walletId`; use per-wallet `amount` / `valueUsd` and parent `priceUsd`
   - Use top-level `wallets[]` for selector labels and per-wallet rollups

3. **Scoped HF:** Re-apply lowest-finite rule on filtered `defiRisk.positionsHealth`, or read pre-aggregated HF from `wallets[]` / `protocolSummaries`.

Requires `includeWallets=true` (default) for per-wallet row filtering.

## Wallet Breakdown

```http
GET /portfolio
GET /portfolio?includeWallets=false
```

When `includeWallets=false`, nested `wallets` arrays are empty; two-level wallet filtering is not possible without the top-level `wallets` selector totals.

## Empty Portfolio

User with no wallets:

```json
{
  "wallets": [],
  "protocolSummaries": [
    {
      "protocol": "wallet",
      "protocolName": "Wallet",
      "category": "wallet",
      "walletValueUsd": "0.00",
      "totalValueUsd": "0.00",
      "healthFactorStatus": "none",
      "networks": []
    }
  ]
}
```

Other sections follow existing empty behavior (`networks: []`, zero totals, etc.).

## Numeric Precision Policy

All public money/token numeric values that can exceed JavaScript safe precision are strings. Use decimal-safe libraries on the frontend; do not use floating-point math for balances or USD totals.

## Error Responses

Missing or invalid token:

```http
401 Unauthorized
```

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Missing or invalid Authorization header."
  }
}
```

Invalid or expired JWT:

```http
401 Unauthorized
```

```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Invalid or expired access token."
  }
}
```

Unexpected server error:

```http
500 Internal Server Error
```

```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "Internal server error."
  }
}
```
