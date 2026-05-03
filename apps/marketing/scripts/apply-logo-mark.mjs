/**
 * Makes square PNG corners transparent (circular mask) and writes public/assets/cryprice-logo-mark.png
 *
 * Usage: node scripts/apply-logo-mark.mjs [input.png]
 */
import { mkdir } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import sharp from 'sharp'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const outPath = join(root, 'public', 'assets', 'cryprice-logo-mark.png')
const inputPath = process.argv[2] ?? join(__dirname, 'logo-source.png')

const EDGE_SOFT = 1.25

async function main() {
  const { data, info } = await sharp(inputPath)
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true })

  const w = info.width
  const h = info.height
  const cx = (w - 1) / 2
  const cy = (h - 1) / 2
  const R = Math.min(w, h) / 2

  const out = new Uint8ClampedArray(data)
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const d = Math.hypot(x - cx, y - cy)
      const i = (y * w + x) * 4
      if (d >= R) {
        out[i + 3] = 0
      } else if (d > R - EDGE_SOFT) {
        const t = (R - d) / EDGE_SOFT
        out[i + 3] = Math.round(out[i + 3] * Math.max(0, Math.min(1, t)))
      }
    }
  }

  await mkdir(dirname(outPath), { recursive: true })
  await sharp(Buffer.from(out), { raw: { width: w, height: h, channels: 4 } })
    .png()
    .toFile(outPath)

  console.log('Wrote', outPath)
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
