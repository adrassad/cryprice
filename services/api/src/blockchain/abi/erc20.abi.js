export const ERC20_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
];

/** Minimal fragment for balance reads only */
export const ERC20_BALANCE_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
];

export const ERC20_STRING_ABI = [
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
];

export const ERC20_BYTES32_ABI = ["function symbol() view returns (bytes32)"];
