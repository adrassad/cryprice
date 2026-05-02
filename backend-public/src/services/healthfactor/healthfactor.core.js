//src/services/healthfactor/healthfactor.core.js
import { db } from "../../db/index.js";
import { getUserHealthFactor } from "../../blockchain/index.js";
import { normalizeAdapterHealthFactor } from "./healthfactor.normalize.js";

export { normalizeAdapterHealthFactor } from "./healthfactor.normalize.js";

/**
 * Adapter returns { healthFactor, collected_at } where healthFactor is from parseHealthFactor:
 * null (missing/error), Infinity (e.g. MaxUint256 / no debt), or a finite number.
 */
export async function calculateAndStoreHF({
  address,
  network,
  checkChange = true,
}) {
  const rawHF = await getUserHealthFactor(network.name, "aave", address);
  const hf = rawHF.healthFactor;

  const { healthfactor, skip } = normalizeAdapterHealthFactor(hf);
  if (skip) {
    return {
      address,
      network: network.name,
      healthfactor: null,
      isChanged: false,
      collected_at: rawHF.collected_at,
    };
  }

  let isChanged = true;

  if (checkChange) {
    isChanged = await db.hf.create({
      address: address,
      protocol: "aave",
      network_id: network.id,
      healthfactor,
      collected_at: rawHF.collected_at,
    });
  }

  return {
    address,
    network: network.name,
    healthfactor,
    isChanged,
    collected_at: rawHF.collected_at,
  };
}
