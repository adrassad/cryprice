/** Includes 0 and Infinity; excludes null/undefined. */
export function hasPersistedHealthFactor(hfResult) {
  return hfResult?.healthfactor != null;
}

/** Networks where HF changed and fell below the user threshold (one wallet). */
export function collectChangedBelowThresholdNetworks(
  address,
  mapHF,
  networks,
  thresholdHf,
) {
  const networkMap = new Map();
  for (const network of Object.values(networks)) {
    const resultHF = mapHF.get(address)?.get(network.name);
    if (
      resultHF &&
      resultHF.isChanged &&
      Number(thresholdHf) > resultHF.healthfactor
    ) {
      networkMap.set(network.name, resultHF.healthfactor);
    }
  }
  return networkMap;
}
