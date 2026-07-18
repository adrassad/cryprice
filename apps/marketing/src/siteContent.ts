/** Edit this file to update copy, links, and author details. */

import authorPhoto from './assets/author.jpg'

export const ROUTES = {
  about: '/about',
  privacy: '/privacy',
  terms: '/terms',
  security: '/security',
  trust: '/trust',
  transparency: '/transparency',
  faq: '/faq',
  contact: '/contact',
  cookies: '/cookies',
  docs: '/docs',
  supportedProtocols: '/supported-protocols',
  changelog: '/changelog',
  status: '/status',
} as const

export const LINKS = {
  app: 'https://app.cryprice.dev',
  api: 'https://api.cryprice.dev',
  /** Cryprice monorepository (API, web, marketing, docs) */
  monoRepo: 'https://github.com/adrassad/cryprice',
  webAppPath: 'https://github.com/adrassad/cryprice/tree/main/apps/web',
  backendPath: 'https://github.com/adrassad/cryprice/tree/main/services/api',
  /** General GitHub profile or org — adjust if you prefer a different landing URL */
  githubProfile: 'https://github.com/adrassad',
  /** Replace with your real LinkedIn URL */
  linkedIn: 'https://www.linkedin.com/in/adrassad',
  xProfile: 'https://x.com/AdrasSad',
  telegram: 'https://t.me/adrassad',
} as const

export const OFFICIAL_DOMAINS = [
  { label: 'cryprice.dev', href: 'https://cryprice.dev/' },
  { label: 'app.cryprice.dev', href: `${LINKS.app}/` },
  { label: 'api.cryprice.dev', href: 'https://api.cryprice.dev/' },
] as const

/** Open app.cryprice.dev in a new tab from the marketing site. */
export const APP_LINK_PROPS = {
  target: '_blank',
  rel: 'noopener noreferrer',
} as const

/** Public contact details for legal and security pages */
export const CONTACT = {
  supportEmail: 'support@cryprice.dev',
  supportMailto: 'mailto:support@cryprice.dev',
  securityEmail: 'security@cryprice.dev',
  securityMailto: 'mailto:security@cryprice.dev',
  legalEmail: 'legal@cryprice.dev',
  legalMailto: 'mailto:legal@cryprice.dev',
  privacyEmail: 'privacy@cryprice.dev',
  privacyMailto: 'mailto:privacy@cryprice.dev',
  pressEmail: 'press@cryprice.dev',
  pressMailto: 'mailto:press@cryprice.dev',
  founderEmail: 'founder@cryprice.dev',
  founderMailto: 'mailto:founder@cryprice.dev',
  /** General public inquiries */
  publicContactEmail: 'support@cryprice.dev',
  publicContactMailto: 'mailto:support@cryprice.dev',
  securityTxtUrl: 'https://cryprice.dev/.well-known/security.txt',
  securityPolicyUrl: 'https://cryprice.dev/security',
  trustUrl: 'https://cryprice.dev/trust',
  transparencyUrl: 'https://cryprice.dev/transparency',
  contactPageUrl: 'https://cryprice.dev/contact',
  githubSecurityPolicyUrl: 'https://github.com/adrassad/cryprice/blob/main/SECURITY.md',
  xProfile: LINKS.xProfile,
} as const

/** Read-only trust guarantees for reuse across trust pages */
export const TRUST_GUARANTEES = [
  'Never requests seed phrases',
  'Never stores private keys',
  'Never signs transactions',
  'Never executes blockchain transactions',
  'Never takes custody of assets',
] as const

/** Static files from /public */
export const ASSETS = {
  /** Header mark: circular logo with “C” (PNG in public/assets) */
  logoMark: '/assets/cryprice-logo-mark.png',
} as const

export const HOME_META = {
  title: 'CryPrice — Read-Only DeFi Risk Intelligence',
  description:
    'CryPrice is a read-only DeFi risk intelligence project for public address monitoring, portfolio visibility, and market risk context.',
  path: '/',
} as const

export const HERO = {
  eyebrow: 'Read-only · Non-custodial · Public address monitoring',
  title: 'Read-Only DeFi Risk Monitoring',
  subheadline:
    'Monitor Aave Health Factor, protocol exposure, and portfolio risk across Ethereum, Arbitrum, Avalanche, and Base using public addresses you choose to track.',
  primaryCta: 'Use CryPrice',
  secondaryCta: 'Read Security Model',
} as const

export const TRUST_STRIP = [
  'Read-only',
  'Non-custodial',
  'Public address monitoring',
] as const

export const SAFETY_MODEL = {
  title: 'Read-only by design',
  lead: 'CryPrice is built for monitoring and risk visibility using public on-chain data. The detailed security model is documented separately.',
  bullets: [
    'Public address monitoring',
    'Non-custodial risk visibility',
    'Optional notifications',
  ] as const,
  ctaLabel: 'Read the Security Model',
  ctaPath: ROUTES.security,
} as const

export const PROBLEM = {
  title: 'DeFi risk is fragmented',
  lead: 'Borrowing and lending exposure is spread across public addresses, protocols, networks, dashboards, and notification channels. Users often see liquidation risk too late — after collateral moves, Health Factor drops, or market conditions shift overnight.',
  points: [
    'On-chain balances live in one place; Aave supplied and borrowed positions in another.',
    'Health Factor and liquidation proximity are easy to miss until thresholds are breached.',
    'Protocol and network allocation require manual reconciliation across explorers and dashboards.',
    'Price and risk notifications are scattered across exchanges, bots, and notification settings.',
  ] as const,
} as const

export const SOLUTION = {
  title: 'One read-only monitoring layer',
  lead: 'CryPrice brings portfolio visibility, Aave V3 position tracking, Health Factor monitoring, protocol exposure, allocation views, prices, PDF reports, and optional Telegram notifications into a single infrastructure stack — without executing transactions or storing private keys.',
  points: [
    'Aggregate multi-address holdings and DeFi positions across Ethereum, Arbitrum, Avalanche, and Base.',
    'Monitor stored Aave V3 Health Factor data and review supplied and borrowed exposure.',
    'Understand allocation by asset, debt, protocol, network, and public address from backend-calculated views.',
    'Receive optional Telegram notifications for Health Factor thresholds and price movements.',
  ] as const,
} as const

export const FEATURES = {
  title: 'Built for DeFi users who borrow, lend, and manage risk',
  lead: 'Portfolio intelligence and risk monitoring across supported networks — with a price calculator as a supporting utility.',
  cards: [
    {
      title: 'Multi-address portfolio dashboard',
      detail:
        'Portfolio visibility: see holdings and DeFi positions across supported networks for public addresses you track.',
    },
    {
      title: 'Aave V3 Health Factor monitoring',
      detail:
        'Aave Health Factor: monitor lending risk and liquidation proximity from stored Health Factor data.',
    },
    {
      title: 'Supplied and borrowed positions',
      detail:
        'Track Aave V3 supplied collateral and borrowed debt alongside address-level balances.',
    },
    {
      title: 'Protocol and network exposure',
      detail:
        'Protocol exposure: understand where your supplied collateral and borrowed debt are concentrated.',
    },
    {
      title: 'Allocation intelligence',
      detail:
        'Allocation intelligence: review backend-calculated allocation by asset, debt, protocol, network, and public address.',
    },
    {
      title: 'Optional Telegram notifications',
      detail: 'Optional Telegram notifications after account setup.',
    },
    {
      title: 'PDF portfolio reports',
      detail:
        'PDF reports: export portfolio snapshots generated server-side.',
    },
    {
      title: 'CEX/DEX price calculator',
      detail:
        'Supporting utility for cross-venue price comparison — not the core product, but available in the product dashboard.',
    },
  ] as const,
  scopeNote:
    'Currently focused on Aave V3, with architecture prepared for additional DeFi protocols.',
} as const

export const HOW_IT_WORKS = {
  title: 'How it works',
  lead: 'Set up read-only monitoring in four steps — no wallet connection required.',
  steps: [
    {
      title: 'Use Google for account access',
      detail:
        'Use Google OAuth for CryPrice account access only. CryPrice never connects to your wallet.',
    },
    {
      title: 'Add public addresses',
      detail: 'Add the public addresses you want to monitor — no private keys required.',
    },
    {
      title: 'CryPrice syncs your data',
      detail:
        'The backend aggregates balances, Aave V3 positions, prices, and Health Factor across supported networks.',
    },
    {
      title: 'Review risk and optional notifications',
      detail:
        'Review portfolio allocation and exposure in the dashboard, link Telegram for optional notifications, and receive threshold alerts.',
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
  sectionTitle: 'Founder / Builder',
  subtitle: 'CryPrice is built in public by Andrei Sharapov.',
  body: 'Andrei is a backend/Web3 developer focused on DeFi risk monitoring, Aave Health Factor analytics, portfolio visibility, and market-event risk intelligence. CryPrice is a founder-led project built to help users understand portfolio and protocol risk before market stress turns into forced liquidations.',
  /** X (Twitter) handle without URL */
  xHandle: '@AdrasSad',
  /** LinkedIn link label in the author social row */
  linkedInLabel: 'LinkedIn',
  /** Resolved by Vite from `src/assets/author.jpg` */
  photoSrc: authorPhoto,
  photoAlt: 'Portrait of Andrei Sharapov',
} as const

export const TECHNICAL_CONTRIBUTIONS = {
  title: 'Technical contributions',
  lead: 'Core engineering areas implemented in the CryPrice stack.',
  items: [
    {
      title: 'Multi-address, multi-chain portfolio aggregation',
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
      detail: 'Allocation views by asset, debt, protocol, network, and public address.',
    },
    {
      title: 'Server-side PDF portfolio reports',
      detail: 'Portfolio snapshots exported via backend PDF generation.',
    },
    {
      title: 'Optional Telegram notifications after Google account access',
      detail:
        'Link Telegram for optional notifications configured from the user profile after account access is set up.',
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
      title: 'Multi-address portfolio dashboard',
      detail: 'Flutter web dashboard for holdings and positions across networks.',
    },
    {
      title: 'Aave V3 Health Factor monitoring',
      detail: 'Health Factor tracking and risk visibility for Aave V3 positions.',
    },
    {
      title: 'Optional Telegram notifications',
      detail: 'Link Telegram for optional Health Factor and price notifications.',
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
  lead: 'CryPrice combines a Flutter Web frontend, Node.js backend, PostgreSQL persistence, Redis caching, scheduled blockchain data sync, protocol adapters, and optional Telegram notifications into a read-only DeFi monitoring stack.',
  flow: [
    'Public addresses',
    'Blockchain adapters',
    'Portfolio aggregation',
    'Risk classification',
    'Web dashboard / optional notifications / PDF reports',
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
        'Durable storage for accounts, public address configuration, Health Factor history, and application state.',
    },
    {
      title: 'Redis caching',
      detail: 'Low-latency caching for price-related workloads and alert processing paths.',
    },
    {
      title: 'Alerting system',
      detail:
        'Telegram bot integration for Health Factor threshold and price movement notifications.',
    },
    {
      title: 'Flutter web frontend',
      detail:
        'Portfolio dashboard, allocation charts, public address management, EN/RU localization, and dark/light theme.',
    },
  ] as const,
  flow: [
    'Flutter Web / Telegram',
    'REST API',
    'Monitoring Engine',
    'Blockchain & Market Data',
    'PostgreSQL / Redis',
    'Alerts & Reports',
  ] as const,
} as const

export const PROJECT_LINK_CARDS = [
  {
    title: 'Use CryPrice',
    href: LINKS.app,
    url: 'app.cryprice.dev',
    external: true,
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
  'CryPrice is a read-only monitoring tool. It does not connect wallets, execute transactions, store private keys, or provide financial advice.' as const
