import express from "express";
import { createReadStream } from "node:fs";
import { access, stat } from "node:fs/promises";
import path from "node:path";
import { ENV } from "../../config/env.js";

const router = express.Router();

const NATIVE_ICON_FILE = "native.png";
const EVM_ICON_FILE_PATTERN = /^0x[a-f0-9]{40}\.png$/;

function parsePositiveChainId(raw) {
  if (raw === undefined || raw === null || raw === "") return null;
  const value = String(raw);
  if (!/^\d+$/.test(value)) return null;
  const chainId = Number(value);
  if (!Number.isSafeInteger(chainId) || chainId <= 0) return null;
  return chainId;
}

function isAllowedIconFileName(file) {
  if (typeof file !== "string" || file === "") return false;
  if (file.includes("/") || file.includes("\\") || file.includes("..")) {
    return false;
  }
  if (file === NATIVE_ICON_FILE) return true;
  return EVM_ICON_FILE_PATTERN.test(file);
}

function isPathInsideRoot(rootDir, targetPath) {
  const resolvedRoot = path.resolve(rootDir);
  const resolvedTarget = path.resolve(targetPath);
  const relative = path.relative(resolvedRoot, resolvedTarget);
  return (
    relative !== ".." &&
    !relative.startsWith(`..${path.sep}`) &&
    !path.isAbsolute(relative)
  );
}

function resolveSafeIconPath(chainId, file) {
  const iconsRoot = path.resolve(ENV.TOKEN_ICONS_DIR);
  const chainSegment = String(chainId);
  const chainDir = path.join(iconsRoot, chainSegment);
  const filePath = path.join(chainDir, file);

  if (!isPathInsideRoot(iconsRoot, filePath)) return null;

  const relative = path.relative(iconsRoot, filePath);
  const segments = relative.split(path.sep);
  if (segments.length !== 2 || segments[0] !== chainSegment || segments[1] !== file) {
    return null;
  }

  return filePath;
}

router.get("/:chainId/:file", async (req, res, next) => {
  try {
    const chainId = parsePositiveChainId(req.params.chainId);
    const file = req.params.file;

    if (chainId === null) {
      return res.status(400).json({ error: "Invalid chainId" });
    }
    if (!isAllowedIconFileName(file)) {
      return res.status(400).json({ error: "Invalid file name" });
    }

    const filePath = resolveSafeIconPath(chainId, file);
    if (!filePath) {
      return res.status(400).json({ error: "Invalid icon path" });
    }

    try {
      await access(filePath);
      const fileStat = await stat(filePath);
      if (!fileStat.isFile()) {
        return res.sendStatus(404);
      }
    } catch {
      return res.sendStatus(404);
    }

    res.setHeader("Content-Type", "image/png");
    res.setHeader("Cache-Control", "public, max-age=604800, immutable");
    res.setHeader("X-Content-Type-Options", "nosniff");

    const stream = createReadStream(filePath);
    stream.on("error", (err) => {
      if (!res.headersSent) next(err);
    });
    stream.pipe(res);
  } catch (err) {
    next(err);
  }
});

export default router;
