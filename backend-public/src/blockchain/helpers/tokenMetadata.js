// src/blockchain/helpers/tokenMetadata.js
import { Contract, ethers } from "ethers";
import { ERC20 } from "../abi/index.js";

export async function getTokenMetadata(address, provider) {
  let symbol;
  let decimals;

  // symbol
  try {
    const erc20 = new Contract(address, ERC20.ERC20_STRING_ABI, provider);
    symbol = await erc20.symbol();
    decimals = Number(await erc20.decimals());
  } catch {
    // fallback: bytes32
    try {
      const erc20b32 = new Contract(address, ERC20.ERC20_BYTES32_ABI, provider);
      const rawSymbol = await erc20b32.symbol();
      symbol = ethers.decodeBytes32String(rawSymbol);
      decimals = Number(await erc20b32.decimals());
    } catch (e) {
      return null;
    }
  }

  return { address, symbol, decimals };
}
