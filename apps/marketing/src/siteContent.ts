/** Edit this file to update copy, links, and author details. */

import authorPhoto from './assets/author.jpg'

/** Defaults when `VITE_PUBLIC_*` variables from `.env` are not set (official CryPrice URLs). */
const LINK_DEFAULTS = {
  app: 'https://app.cryprice.dev',
  apiHost: 'api.cryprice.dev',
  monoRepo: 'https://github.com/adrassad/cryprice',
  webAppPath: 'https://github.com/adrassad/cryprice/tree/main/apps/web',
  backendPath: 'https://github.com/adrassad/cryprice/tree/main/backend-public',
  githubProfile: 'https://github.com/adrassad',
  linkedIn: 'https://www.linkedin.com/in/adrassad',
  xProfile: 'https://x.com/AdrasSad',
} as const

function fromEnv(name: keyof ImportMetaEnv, fallback: string): string {
  const raw = import.meta.env[name]
  return typeof raw === 'string' && raw.trim() !== '' ? raw.trim() : fallback
}

export const LINKS = {
  app: fromEnv('VITE_PUBLIC_APP_URL', LINK_DEFAULTS.app),
  monoRepo: fromEnv('VITE_PUBLIC_MONOREPO_URL', LINK_DEFAULTS.monoRepo),
  webAppPath: fromEnv('VITE_PUBLIC_WEB_APP_PATH_URL', LINK_DEFAULTS.webAppPath),
  backendPath: fromEnv('VITE_PUBLIC_BACKEND_PATH_URL', LINK_DEFAULTS.backendPath),
  githubProfile: fromEnv('VITE_PUBLIC_GITHUB_PROFILE_URL', LINK_DEFAULTS.githubProfile),
  linkedIn: fromEnv('VITE_PUBLIC_LINKEDIN_URL', LINK_DEFAULTS.linkedIn),
  xProfile: fromEnv('VITE_PUBLIC_X_PROFILE_URL', LINK_DEFAULTS.xProfile),
} as const

/** Shown in footer; hostname only, no scheme. */
export const PUBLIC_API_HOST = fromEnv('VITE_PUBLIC_API_HOST', LINK_DEFAULTS.apiHost)

export function urlHostname(url: string, fallback: string): string {
  try {
    return new URL(url).hostname
  } catch {
    return fallback
  }
}

/** `user/repo` from a github.com repository URL */
export function githubRepoLabel(repoUrl: string, fallback: string): string {
  try {
    const path = new URL(repoUrl).pathname.replace(/^\/+|\/+$/g, '')
    return path || fallback
  } catch {
    return fallback
  }
}

/** Static files from /public */
export const ASSETS = {
  /** Header mark: circular logo with “C” (PNG in public/assets) */
  logoMark: '/assets/cryprice-logo-mark.png',
} as const

export const AUTHOR = {
  name: 'Andrei Sharapov',
  /** Shown directly under the name on the landing page */
  title: 'Systems Architect & Full-Stack Developer',
  /** X (Twitter) handle without URL */
  xHandle: '@AdrasSad',
  /** LinkedIn link label in the author social row */
  linkedInLabel: 'LinkedIn',
  bioParagraphs: [
    'I architect and ship full-stack products where Web3 meets market data—backend infrastructure, ingestion and normalization pipelines, and client applications that feel like a single product rather than a stack of disconnected utilities.',
    'Cryprice exists to fix inconsistent reads on the same market: it aggregates pricing across CEX and DEX liquidity, aligns it for fair comparison, and delivers timely context for teams and individuals who split time between centralized venues and on-chain activity.',
    'On top of pricing, it adds alerting shaped for DeFi workflows—including visibility into Aave positions and related risk—so meaningful moves surface without juggling multiple monitors. The goal is a dependable layer for context and awareness, not noise or trading promises.',
  ] as const,
  /** Resolved by Vite from `src/assets/author.jpg` */
  photoSrc: authorPhoto,
  photoAlt: 'Portrait of Andrei Sharapov',
  techTags: [
    'System Architecture',
    'Web3',
    'Market Data',
    'Aave V3',
    'Ethers.js',

    'Node.js',
    'Express',
    'PostgreSQL',
    'Redis',

    'Flutter',
    'Dart',
    'BLoC',
    'Dio',

    'Google Sign-In',
    'Telegram (in-app)',
  ] as const,
} as const

export const ABOUT_CRYPRICE = [
  'Compare prices across centralized exchanges, decentralized venues, and aggregators in one place.',
  'Run direct, reverse, and cross-rate calculations without leaving the app.',
  'The product also includes a Telegram bot for quick checks and alert-style workflows—it lives inside the same app experience on app.cryprice.dev, not as a separate destination.',
  'Sign in with Google where the product needs it; the stack is a Flutter web/app frontend talking to a Node.js API.',
] as const

export const TECH_STACK_CARDS = [
  { title: 'Flutter frontend', detail: 'Web and app surfaces from a single codebase.' },
  { title: 'Node.js backend', detail: 'REST APIs and integrations behind the product.' },
  { title: 'PostgreSQL', detail: 'Durable storage for accounts and app data.' },
  { title: 'Redis', detail: 'Caching and fast paths for price-related workloads.' },
  { title: 'Google Auth', detail: 'Familiar sign-in where the flow requires it.' },
  {
    title: 'Telegram (in-app)',
    detail:
      'Bot flows are part of Cryprice—use them from app.cryprice.dev together with the web and mobile surfaces.',
  },
  { title: 'CEX / DEX data', detail: 'Feeds from exchanges and on-chain sources — presented clearly, not as trading advice.' },
] as const
