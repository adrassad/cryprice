// src/services/portfolio/portfolio.collector.js
import pLimit from "p-limit";
import { Contract } from "ethers";
import { networksRegistry } from "../../blockchain/networks/index.js";
import { ERC20_BALANCE_ABI } from "../../blockchain/abi/erc20.abi.js";
import { getEnabledNetworks } from "../network/network.service.js";
import { listAssetsByNetworkFromDb } from "../asset/asset.service.js";
import { listActiveProtocolAssetTokensByNetwork } from "../protocolAsset/protocolAsset.service.js";

/** Conservative shared limit for all RPC reads (native + ERC20 per asset). */
const RPC_CONCURRENCY = 6;

/**
 * Native gas token uses 18 decimals on Ethereum, Arbitrum, Avalanche C-Chain, Base
 * (matches JsonRpcProvider.getBalance wei semantics).
 */
const EVM_NATIVE_DECIMALS_WEI = 18;

function normalizeWalletAddress(walletAddress) {
  if (!walletAddress || typeof walletAddress !== "string") {
    throw new Error("walletAddress is required");
  }
  const addr = walletAddress.trim().toLowerCase();
  if (!/^0x[a-f0-9]{40}$/.test(addr)) {
    throw new Error("walletAddress must be a 42-char hex EVM address");
  }
  return addr;
}

function positionSideFromTokenRole(tokenRole) {
  if (tokenRole === "supply_token") return "supplied";
  if (tokenRole === "stable_debt_token" || tokenRole === "variable_debt_token") {
    return "borrowed";
  }
  return null;
}

/**
 * On-chain ERC20 + native balances for one wallet across enabled networks.
 * Read-only: no DB writes, no HTTP price APIs.
 *
 * @param {string} walletAddress
 * @returns {Promise<{
 *   walletAddress: string,
 *   collectedAt: string,
 *   networks: Array<{
 *     networkId: number,
 *     networkName: string,
 *     chainId: number,
 *     status: 'ok'|'degraded'|'skipped',
 *     skipReason?: string,
 *     native: null | { kind: 'native', symbol: string, decimals: number, balanceRaw: string },
 *     tokens: Array<{
 *       kind: 'erc20',
 *       assetId: string,
 *       address: string,
 *       symbol: string,
 *       decimals: number,
 *       balanceRaw: string,
 *     }>,
 *     protocolPositions: Array<{
 *       kind: 'protocol',
 *       protocol: string,
 *       protocolAssetTokenId: string,
 *       tokenRole: string,
 *       positionSide: 'supplied'|'borrowed',
 *       underlyingAssetId: string,
 *       priceAssetId: string|null,
 *       tokenAddress: string,
 *       tokenSymbol: string,
 *       tokenDecimals: number,
 *       balanceRaw: string,
 *     }>,
 *   }>,
 * }>}
 */
export async function collectWalletPortfolio(walletAddress) {
  const wallet = normalizeWalletAddress(walletAddress);
  const networksMap = await getEnabledNetworks();
  const networks = Object.values(networksMap ?? {}).filter(
    (n) =>
      n &&
      typeof n === "object" &&
      n.enabled !== false &&
      n.id != null &&
      typeof n.name === "string",
  );

  const limit = pLimit(RPC_CONCURRENCY);
  const collectedAt = new Date().toISOString();

  const networkResults = await Promise.all(
    networks.map(async (netMeta) => {
      const registry = networksRegistry[netMeta.name];
      if (!registry?.provider) {
        return {
          networkId: netMeta.id,
          networkName: netMeta.name,
          chainId: netMeta.chain_id,
          status: "skipped",
          skipReason: "no_registry_provider",
          native: null,
          tokens: [],
          protocolStatus: "skipped",
          protocolPositions: [],
        };
      }

      const provider = registry.provider;
      let hadRpcErrors = false;

      let native = null;
      try {
        const wei = await limit(() => provider.getBalance(wallet));
        if (wei > 0n) {
          native = {
            kind: "native",
            symbol:
              netMeta.native_symbol != null
                ? String(netMeta.native_symbol)
                : "",
            decimals: EVM_NATIVE_DECIMALS_WEI,
            balanceRaw: wei.toString(),
          };
        }
      } catch {
        // Mark network degraded; never treat partial RPC failures as fully healthy.
        hadRpcErrors = true;
      }

      const rawAssets = await listAssetsByNetworkFromDb(netMeta.id);
      const assets = Array.isArray(rawAssets) ? rawAssets : [];

      const tokenRows = await Promise.all(
        assets.map((asset) =>
          limit(async () => {
            try {
              if (
                !asset ||
                asset.address == null ||
                asset.id == null
              ) {
                return null;
              }
              const contract = new Contract(
                String(asset.address).trim(),
                ERC20_BALANCE_ABI,
                provider,
              );
              const raw = await contract.balanceOf(wallet);
              if (raw <= 0n) return null;
              return {
                kind: "erc20",
                assetId: String(asset.id),
                address: String(asset.address).toLowerCase(),
                symbol: asset.symbol != null ? String(asset.symbol) : "",
                decimals:
                  typeof asset.decimals === "number" &&
                  Number.isFinite(asset.decimals)
                    ? asset.decimals
                    : Number(asset.decimals) || 0,
                balanceRaw: raw.toString(),
              };
            } catch {
              hadRpcErrors = true;
              return null;
            }
          }),
        ),
      );

      const tokens = tokenRows.filter(Boolean);
      let hadProtocolRpcErrors = false;
      const protocolTokens = await listActiveProtocolAssetTokensByNetwork(
        netMeta.id,
      );

      const protocolRows = await Promise.all(
        protocolTokens.map((token) =>
          limit(async () => {
            try {
              const positionSide = positionSideFromTokenRole(token.token_role);
              if (!positionSide || !token.token_address || token.id == null) {
                return null;
              }

              const contract = new Contract(
                String(token.token_address).trim(),
                ERC20_BALANCE_ABI,
                provider,
              );
              const raw = await contract.balanceOf(wallet);
              if (raw <= 0n) return null;

              return {
                kind: "protocol",
                protocol: String(token.protocol),
                protocolAssetTokenId: String(token.id),
                tokenRole: String(token.token_role),
                positionSide,
                underlyingAssetId: String(token.underlying_asset_id),
                priceAssetId:
                  token.price_asset_id != null ? String(token.price_asset_id) : null,
                tokenAddress: String(token.token_address).toLowerCase(),
                tokenSymbol:
                  token.token_symbol != null ? String(token.token_symbol) : "",
                tokenDecimals:
                  typeof token.token_decimals === "number" &&
                  Number.isFinite(token.token_decimals)
                    ? token.token_decimals
                    : Number(token.token_decimals) || 0,
                balanceRaw: raw.toString(),
              };
            } catch {
              hadProtocolRpcErrors = true;
              return null;
            }
          }),
        ),
      );

      const protocolPositions = protocolRows.filter(Boolean);

      return {
        networkId: netMeta.id,
        networkName: netMeta.name,
        chainId: netMeta.chain_id,
        status: hadRpcErrors ? "degraded" : "ok",
        native,
        tokens,
        protocolStatus: hadProtocolRpcErrors ? "degraded" : "ok",
        protocolPositions,
      };
    }),
  );

  return {
    walletAddress: wallet,
    collectedAt,
    networks: networkResults,
  };
}
