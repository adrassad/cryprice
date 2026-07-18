export const SITE_ORIGIN = 'https://cryprice.dev'
export const SITE_NAME = 'CryPrice'
export const TWITTER_SITE = '@AdrasSad'
export const OG_IMAGE_PATH = '/assets/og-image.png'
export const OG_IMAGE = `${SITE_ORIGIN}${OG_IMAGE_PATH}`
export const OG_IMAGE_WIDTH = 1200
export const OG_IMAGE_HEIGHT = 630
export const ROBOTS_CONTENT = 'index, follow, max-image-preview:large'

/** Canonical paths use trailing slashes (except home) to match production URLs. */
export function canonicalPath(path: string): string {
  if (path === '/') {
    return '/'
  }
  return path.endsWith('/') ? path : `${path}/`
}

export function canonicalUrl(path: string): string {
  return `${SITE_ORIGIN}${canonicalPath(path)}`
}
