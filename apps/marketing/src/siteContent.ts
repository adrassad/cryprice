/** Edit this file to update copy, links, and author details. */

import authorPhoto from './assets/author.jpg'

/** Defaults when `VITE_PUBLIC_*` variables from `.env` are not set. */
const LINK_DEFAULTS = {
  app: 'https://app.cryprice.dev',
  apiHost: 'api.cryprice.dev',
  monoRepo: 'https://github.com/adrassad/cryprice',
  webAppPath: 'https://github.com/adrassad/cryprice/tree/main/apps/web',
  backendPath: 'https://github.com/adrassad/cryprice/tree/main/services/api',
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

export const PUBLIC_API_HOST = fromEnv('VITE_PUBLIC_API_HOST', LINK_DEFAULTS.apiHost)

/** Static files from /public */
export const ASSETS = {
  /** Header mark: circular logo with “C” (PNG in public/assets) */
  logoMark: '/assets/cryprice-logo-mark.png',
} as const

export const HERO = {
  eyebrow: 'Read-only · multi-chain · DeFi risk monitoring',
  title: 'Multi-Chain DeFi Risk Monitoring Infrastructure',
  subheadline:
    'Track wallets, Aave positions, Health Factor, protocol exposure, and portfolio allocation across multiple networks — without giving up custody or private keys.',
  primaryCta: 'Open App',
  secondaryCta: 'Monitor DeFi Risk Early',
} as const

export const TRUST_STRIP = [
  'Read-only monitoring',
  'No private keys',
  'Multi-wallet visibility',
  'Aave V3 Health Factor',
  'Authenticated Telegram alerts',
] as const

export const PROBLEM = {
  title: 'DeFi risk is fragmented',
  lead: 'Borrowing and lending exposure is spread across wallets, protocols, networks, dashboards, and alert channels. Users often see liquidation risk too late — after collateral moves, Health Factor drops, or market conditions shift overnight.',
  points: [
    'Wallet balances live in one place; Aave supplied and borrowed positions in another.',
    'Health Factor and liquidation proximity are easy to miss until thresholds are breached.',
    'Protocol and network allocation require manual reconciliation across explorers and apps.',
    'Price and risk alerts are scattered across exchanges, bots, and notification settings.',
  ] as const,
} as const

export const SOLUTION = {
  title: 'One read-only monitoring layer',
  lead: 'CryPrice brings portfolio visibility, Aave V3 position tracking, Health Factor monitoring, protocol exposure, allocation views, prices, PDF reports, and Telegram alerts into a single infrastructure stack — without executing transactions or storing private keys.',
  points: [
    'Aggregate multi-wallet holdings and DeFi positions across Ethereum, Arbitrum, Avalanche, and Base.',
    'Monitor stored Aave V3 Health Factor data and review supplied and borrowed exposure.',
    'Understand allocation by asset, debt, protocol, network, and wallet from backend-calculated views.',
    'Receive Telegram alerts for Health Factor thresholds and price movements.',
  ] as const,
} as const

export const FEATURES = {
  title: 'Built for DeFi users who borrow, lend, and manage risk',
  lead: 'Portfolio intelligence and risk monitoring across supported networks — with a price calculator as a supporting utility.',
  cards: [
    {
      title: 'Multi-wallet portfolio dashboard',
      detail:
        'Portfolio visibility: see wallet holdings and DeFi positions across supported networks.',
    },
    {
      title: 'Aave V3 Health Factor monitoring',
      detail:
        'Aave Health Factor: monitor lending risk and liquidation proximity from stored Health Factor data.',
    },
    {
      title: 'Supplied and borrowed positions',
      detail:
        'Track Aave V3 supplied collateral and borrowed debt alongside wallet-level balances.',
    },
    {
      title: 'Protocol and network exposure',
      detail:
        'Protocol exposure: understand where your supplied collateral and borrowed debt are concentrated.',
    },
    {
      title: 'Allocation intelligence',
      detail:
        'Allocation intelligence: review backend-calculated allocation by asset, debt, protocol, network, and wallet.',
    },
    {
      title: 'Telegram risk alerts',
      detail:
        'Telegram alerts are available after signing in and linking your Telegram account in the CryPrice app.',
    },
    {
      title: 'PDF portfolio reports',
      detail:
        'PDF reports: export portfolio snapshots generated server-side.',
    },
    {
      title: 'CEX/DEX price calculator',
      detail:
        'Supporting utility for cross-venue price comparison — not the core product, but available in the app.',
    },
  ] as const,
  scopeNote:
    'Currently focused on Aave V3, with architecture prepared for additional DeFi protocols.',
} as const

export const HOW_IT_WORKS = {
  title: 'How it works',
  lead: 'Connect, add wallets, and review risk — read-only from end to end.',
  steps: [
    {
      title: 'Connect with Google',
      detail: 'Sign in to the CryPrice web app with Google authentication.',
    },
    {
      title: 'Add wallet addresses',
      detail: 'Add the wallet addresses you want to monitor — no private keys required.',
    },
    {
      title: 'CryPrice syncs your data',
      detail:
        'The backend aggregates balances, Aave V3 positions, prices, and Health Factor across supported networks.',
    },
    {
      title: 'Review risk and get alerts',
      detail:
        'Review portfolio allocation and exposure in the app, link Telegram, and receive threshold alerts.',
    },
  ] as const,
} as const

export const ROADMAP = {
  title: 'Roadmap',
  lead: 'Planned capabilities — not yet live in the product.',
  items: [
    'Risk Insights — human-readable risk explanations (planned backend layer)',
    'Protocol incident interpretation',
    'Additional DeFi protocols beyond Aave V3 (e.g. Fluid, Lido, BENQI, Uniswap V3/V4)',
    'Historical analytics',
    'CSV/XLSX export',
    'PWA notifications',
  ] as const,
} as const

export const AUTHOR = {
  name: 'Andrei Sharapov',
  sectionTitle: 'Built by an independent DeFi infrastructure builder',
  /** Shown directly under the name on the landing page */
  title: 'Systems Architect & Full-Stack Developer',
  lead: 'CryPrice is built by Andrei Sharapov, a Systems Architect & Full-Stack Developer focused on DeFi risk infrastructure, portfolio intelligence, and blockchain data systems.',
  supportingCopy:
    'The project combines backend architecture, blockchain data aggregation, risk monitoring, Telegram alerting, and Flutter-based product delivery into a single read-only DeFi monitoring stack.',
  /** X (Twitter) handle without URL */
  xHandle: '@AdrasSad',
  /** LinkedIn link label in the author social row */
  linkedInLabel: 'LinkedIn',
  bioParagraphs: [
    'Independent builder of read-only DeFi monitoring systems — from multi-chain portfolio aggregation and Aave V3 risk tracking to alerting and server-side reporting.',
  ] as const,
  /** Resolved by Vite from `src/assets/author.jpg` */
  photoSrc: authorPhoto,
  photoAlt: 'Portrait of Andrei Sharapov',
  techTags: [
    'Backend Architecture',
    'DeFi Risk Monitoring',
    'Aave V3',
    'Multi-Chain',
    'Node.js',
    'Express',
    'PostgreSQL',
    'Redis',
    'Flutter',
    'Google Sign-In',
  ] as const,
} as const

export const TECHNICAL_CONTRIBUTIONS = {
  title: 'Technical contributions',
  lead: 'Core engineering areas implemented in the CryPrice stack.',
  items: [
    {
      title: 'Multi-wallet, multi-chain portfolio aggregation',
      detail: 'Read-only portfolio data across Ethereum, Arbitrum, Avalanche, and Base.',
    },
    {
      title: 'Aave V3 supplied and borrowed position monitoring',
      detail: 'On-chain position reads integrated into portfolio views.',
    },
    {
      title: 'Health Factor risk classification and threshold alerts',
      detail: 'Stored Health Factor data with configurable alert thresholds.',
    },
    {
      title: 'Backend-calculated allocation intelligence',
      detail: 'Allocation views by asset, debt, protocol, network, and wallet.',
    },
    {
      title: 'Server-side PDF portfolio reports',
      detail: 'Portfolio snapshots exported via backend PDF generation.',
    },
    {
      title: 'Authenticated Telegram alert flow after Google sign-in',
      detail: 'Telegram linking and alerts configured from the user profile after authentication.',
    },
    {
      title: 'Protocol-adapter architecture for future DeFi integrations',
      detail: 'Extensible backend design; Aave V3 is the currently implemented adapter.',
    },
    {
      title: 'Read-only architecture with no private key custody',
      detail: 'Monitoring-only stack that does not execute transactions or store private keys.',
    },
  ] as const,
} as const

export const MILESTONES = {
  title: 'Project Milestones',
  lead: 'Development stages for the CryPrice platform — implemented and planned.',
  items: [
    {
      title: 'Price aggregation prototype',
      detail: 'Cross-venue price comparison as a supporting utility.',
    },
    {
      title: 'Multi-wallet portfolio dashboard',
      detail: 'Flutter web dashboard for holdings and positions across networks.',
    },
    {
      title: 'Aave V3 Health Factor monitoring',
      detail: 'Health Factor tracking and risk visibility for Aave V3 positions.',
    },
    {
      title: 'Telegram account linking and risk alerts',
      detail: 'In-app Telegram linking with Health Factor and price alerts.',
    },
    {
      title: 'PDF portfolio reporting',
      detail: 'Server-side PDF export for portfolio snapshots.',
    },
    {
      title: 'Planned: Risk Insights and additional protocol adapters',
      detail: 'Human-readable risk explanations and expanded DeFi protocol support.',
      planned: true,
    },
  ] as const,
} as const

export const PUBLIC_WORK = {
  title: 'Public Research Notes',
  lead: 'Selected public work and commentary around DeFi risk monitoring, Aave infrastructure, protocol incidents, liquidation safety, and AI-assisted risk analysis.',
  links: [
    { label: 'Follow public notes on X', href: LINKS.xProfile },
    { label: 'View engineering work on GitHub', href: LINKS.githubProfile },
  ] as const,
} as const

export const ARCHITECTURE_SNAPSHOT = {
  title: 'Architecture Snapshot',
  lead: 'CryPrice combines a Flutter Web frontend, Node.js backend, PostgreSQL persistence, Redis caching, scheduled blockchain data sync, protocol adapters, and Telegram alerting into a read-only DeFi monitoring stack.',
  flow: [
    'Wallets',
    'Blockchain adapters',
    'Portfolio aggregation',
    'Risk classification',
    'Web dashboard / Telegram alerts / PDF reports',
  ] as const,
} as const

export const INFRASTRUCTURE_OVERVIEW = {
  lead: 'CryPrice is built as a read-only operational stack: ingestion, normalization, storage, and delivery — coordinated through a backend-centric architecture.',
  cards: [
    {
      title: 'REST API layer',
      detail:
        'Application-facing APIs including portfolio aggregation (GET /portfolio) and server-side PDF export (GET /portfolio/export/pdf).',
    },
    {
      title: 'Monitoring engine',
      detail:
        'Services that evaluate DeFi risk conditions, reconcile feeds, and drive alerting logic for Health Factor and prices.',
    },
    {
      title: 'Blockchain integrations',
      detail:
        'On-chain reads and protocol-aware integrations for Aave V3 position monitoring across supported networks.',
    },
    {
      title: 'Background workers',
      detail: 'Cron jobs and asynchronous tasks for feed polling, normalization, cache refresh, and alert dispatch.',
    },
    {
      title: 'Market data normalization',
      detail:
        'Cross-venue price alignment so CEX, DEX, and on-chain sources can be compared consistently.',
    },
    {
      title: 'PostgreSQL storage',
      detail:
        'Durable storage for accounts, wallet configuration, Health Factor history, and application state.',
    },
    {
      title: 'Redis caching',
      detail: 'Low-latency caching for price-related workloads and alert processing paths.',
    },
    {
      title: 'Alerting system',
      detail:
        'Authenticated Telegram alert linking after Google sign-in for Health Factor threshold notifications.',
    },
    {
      title: 'Flutter web frontend',
      detail:
        'Portfolio dashboard, allocation charts, wallet management, EN/RU localization, and dark/light theme.',
    },
  ] as const,
  flow: [
    'Flutter Web / authenticated alerts',
    'REST API',
    'Monitoring Engine',
    'Blockchain & Market Data',
    'PostgreSQL / Redis',
    'Alerts & Reports',
  ] as const,
} as const

export const PROJECT_LINK_CARDS = [
  {
    title: 'Open App',
    href: LINKS.app,
    url: 'app.cryprice.dev',
    external: false,
  },
  {
    title: 'Public Repository',
    href: LINKS.monoRepo,
    url: 'adrassad/cryprice',
    external: true,
  },
  {
    title: 'Web App Source',
    href: LINKS.webAppPath,
    url: 'apps/web',
    external: true,
  },
  {
    title: 'Backend Source',
    href: LINKS.backendPath,
    url: 'services/api',
    external: true,
  },
  {
    title: 'GitHub Profile',
    href: LINKS.githubProfile,
    url: 'github.com/adrassad',
    external: true,
  },
] as const

export const DISCLAIMER =
  'CryPrice is a read-only monitoring tool. It does not execute transactions, store private keys, or provide financial advice.' as const
