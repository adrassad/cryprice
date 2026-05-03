/**
 * Builds an animated GIF: outer ring rotates clockwise; center stays fixed; transparent outside the logo.
 *
 * Usage: node scripts/spin-logo-gif.mjs [input.png] [output.gif]
 * Defaults: scripts/source-cryprice-icon.png -> public/assets/cryprice-logo-spin.gif
 */

import { createWriteStream } from 'node:fs'
import { mkdir } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

import { GifEncoder } from '@skyra/gifenc'
import sharp from 'sharp'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')

const INPUT =
  process.argv[2] ?? join(__dirname, 'source-cryprice-icon.png')
const OUTPUT =
  process.argv[3] ?? join(root, 'public', 'assets', 'cryprice-logo-spin.gif')

/** Max width/height before animation (smaller = lighter GIF). */
const MAX_DIMENSION = 320

/** Inner radius ratio (center + “C” stays static). */
const INNER_R = 0.34
/** Outer radius ratio (visible coin ring). */
const OUTER_R = 0.485
/** Frames per full turn — more = smoother (larger file). */
const FRAMES = 56
/** Delay between frames in ms. */
const FRAME_DELAY_MS = 42
/** Quantization quality (1 = best/slowest). */
const GIF_QUALITY = 8

function applyCircularMask(rgba, w, h, cx, cy, ro) {
  const half = Math.min(w, h) / 2
  const rOut = half * OUTER_R
  const outer = ro ?? rOut
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const d = Math.hypot(x - cx + 0.5, y - cy + 0.5)
      if (d > outer) {
        const i = (y * w + x) * 4
        rgba[i + 3] = 0
      }
    }
  }
}

async function buildRingAndCenterPng(inputPath) {
  const resized = await sharp(inputPath)
    .ensureAlpha()
    .resize(MAX_DIMENSION, MAX_DIMENSION, {
      fit: 'inside',
      withoutEnlargement: true,
    })
    .png()
    .toBuffer()

  const meta = await sharp(resized).metadata()
  const w = meta.width
  const h = meta.height
  const cx = w / 2
  const cy = h / 2
  const half = Math.min(w, h) / 2
  const ri = half * INNER_R
  const ro = half * OUTER_R

  const { data } = await sharp(resized)
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true })

  const src = new Uint8ClampedArray(data)
  const ring = new Uint8ClampedArray(src)
  const center = new Uint8ClampedArray(src)

  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const d = Math.hypot(x - cx + 0.5, y - cy + 0.5)
      const i = (y * w + x) * 4
      if (d > ro) {
        ring[i + 3] = 0
        center[i + 3] = 0
        continue
      }
      if (d < ri) {
        ring[i + 3] = 0
      } else {
        center[i + 3] = 0
      }
    }
  }

  applyCircularMask(ring, w, h, cx, cy, ro)
  applyCircularMask(center, w, h, cx, cy, ro)

  const ringPng = await sharp(Buffer.from(ring), {
    raw: { width: w, height: h, channels: 4 },
  })
    .png()
    .toBuffer()

  const centerPng = await sharp(Buffer.from(center), {
    raw: { width: w, height: h, channels: 4 },
  })
    .png()
    .toBuffer()

  return { w, h, ringPng, centerPng }
}

async function rotateRingCropped(ringPng, w, h, angleDeg) {
  return sharp(ringPng)
    .rotate(angleDeg, {
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .resize(w, h, {
      fit: 'cover',
      position: 'center',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer()
}

async function compositeFrame(w, h, rotatedRingPng, centerPng) {
  const { data } = await sharp({
    create: {
      width: w,
      height: h,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([
      { input: rotatedRingPng, left: 0, top: 0 },
      { input: centerPng, left: 0, top: 0 },
    ])
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true })

  return new Uint8ClampedArray(data)
}

async function main() {
  await mkdir(dirname(OUTPUT), { recursive: true })

  const { w, h, ringPng, centerPng } = await buildRingAndCenterPng(INPUT)

  const encoder = new GifEncoder(w, h)
  encoder
    .setRepeat(0)
    .setDelay(FRAME_DELAY_MS)
    .setQuality(GIF_QUALITY)
    .setTransparent(0x010203)

  const stream = encoder.createReadStream()
  const writeStream = createWriteStream(OUTPUT)
  stream.pipe(writeStream)

  encoder.start()

  for (let i = 0; i < FRAMES; i++) {
    // Clockwise when viewed from the front (Y-down images): negative Sharp angle.
    const angle = -(360 * i) / FRAMES
    const rotated = await rotateRingCropped(ringPng, w, h, angle)
    const frame = await compositeFrame(w, h, rotated, centerPng)
    encoder.addFrame(frame)
  }

  encoder.finish()

  const { finished } = await import('node:stream/promises')
  await finished(writeStream)

  console.log(`Wrote ${OUTPUT} (${w}×${h}, ${FRAMES} frames)`)
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
