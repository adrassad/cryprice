import { ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const ABOUT_META = {
  title: 'About — CryPrice',
  description:
    'About CryPrice: a founder-led, read-only DeFi risk intelligence project for public address monitoring, portfolio visibility, and Aave Health Factor context.',
  path: ROUTES.about,
  lastUpdated: 'July 14, 2026',
} as const

export const ABOUT_SUMMARY =
  'CryPrice is an independent read-only DeFi risk intelligence project built in public. It helps users monitor public blockchain addresses, review portfolio and protocol exposure, and understand Aave Health Factor context — without wallet connection or transaction execution.'

export const ABOUT_SECTIONS: readonly InfoSection[] = [
  {
    id: 'mission',
    title: 'Mission',
    paragraphs: [
      'CryPrice exists to make DeFi borrowing and lending risk easier to observe before market stress turns into forced liquidations. The product focuses on monitoring, visibility, and optional alerts — not custody, trading, or on-chain execution.',
    ],
  },
  {
    id: 'vision',
    title: 'Vision',
    paragraphs: [
      'A world where DeFi participants can see portfolio and protocol risk clearly across wallets and networks — early enough to act on their own terms, without handing custody or signing authority to a monitoring tool.',
    ],
  },
  {
    id: 'what-cryprice-is',
    title: 'What CryPrice is',
    paragraphs: ['CryPrice is a read-only monitoring stack with three public surfaces:'],
    list: [
      'cryprice.dev — product website, documentation, and trust pages',
      'app.cryprice.dev — authenticated web dashboard',
      'api.cryprice.dev — read-only backend API for portfolio and risk data',
    ],
    paragraphsAfterList: [
      'Users add public addresses they want to monitor. CryPrice aggregates balances, Aave V3 positions, Health Factor context, allocation views, and optional notifications configured in the product.',
    ],
  },
  {
    id: 'what-cryprice-is-not',
    title: 'What CryPrice is not',
    paragraphs: ['CryPrice is intentionally not:'],
    list: [
      'a wallet or wallet connector',
      'an exchange or trading venue',
      'a transaction signing or fund custody service',
      'financial, investment, tax, or legal advice',
    ],
  },
  {
    id: 'project-stage',
    title: 'Current Project Stage',
    paragraphs: [
      'CryPrice is an independent startup project in active development, currently pre-incorporation. There is no registered legal entity yet — the product is founder-led and built in public.',
      'For funding context, business model, and development principles, see the Transparency page.',
    ],
  },
  {
    id: 'technology-overview',
    title: 'Technology Overview',
    paragraphs: [
      'CryPrice combines a Flutter Web frontend, Node.js backend, PostgreSQL persistence, Redis caching, BullMQ background workers, protocol adapters, and optional Telegram notifications into a read-only DeFi monitoring stack.',
    ],
    list: [
      'Flutter Web — portfolio dashboard and public address management',
      'Node.js + Express — read-only API, aggregation, alerting, PDF export',
      'PostgreSQL — accounts, addresses, Health Factor history, application state',
      'Redis + BullMQ — caching and asynchronous sync jobs',
      'Cloudflare — CDN delivery for public websites',
    ],
  },
  {
    id: 'infrastructure-overview',
    title: 'Infrastructure Overview',
    paragraphs: [
      'CryPrice is built as a read-only operational stack: ingestion, normalization, storage, and delivery — coordinated through a backend-centric architecture. Public sites are served over HTTPS with DNSSEC where enabled.',
    ],
    list: [
      'REST API layer — portfolio aggregation and server-side PDF export',
      'Monitoring engine — Health Factor and price alert evaluation',
      'Blockchain integrations — on-chain reads for Aave V3 across supported networks',
      'Background workers — feed polling, normalization, cache refresh, alert dispatch',
    ],
  },
  {
    id: 'open-source',
    title: 'Open Source',
    paragraphs: [
      'Public engineering work is available on GitHub. CryPrice publishes repositories and documentation for transparency — see the repository link on the homepage and Contact page.',
      'Repository: https://github.com/adrassad/cryprice',
    ],
  },
  {
    id: 'development-philosophy',
    title: 'Development Philosophy',
    paragraphs: ['CryPrice is developed with these principles:'],
    list: [
      'Read-only by design — no private keys, no transaction execution, no custody',
      'Truthful public documentation — no invented legal entity or certifications',
      'Backend-owned aggregation for consistent portfolio and risk views',
      'Responsible disclosure for security issues',
      'Built in public with verifiable engineering artifacts',
    ],
  },
  {
    id: 'roadmap',
    title: 'Roadmap',
    paragraphs: [
      'Planned capabilities are listed on the CryPrice homepage Roadmap section. Items there are planned — not all are live yet.',
      'See Roadmap: https://cryprice.dev/#roadmap',
    ],
  },
  {
    id: 'transparency',
    title: 'Transparency & Trust',
    paragraphs: [
      'For project status, funding context, and official contacts, see the Transparency and Trust pages.',
      'Transparency: /transparency · Trust hub: /trust · Security model: /security',
    ],
  },
  {
    id: 'founder',
    title: 'Founder / builder',
    paragraphs: [
      'CryPrice is built in public by Andrei Sharapov, a backend and Web3 developer focused on DeFi risk monitoring, Aave infrastructure, and portfolio intelligence.',
      'Public engineering work is available on GitHub. Product updates and research notes are shared on X and Telegram.',
    ],
  },
  {
    id: 'official-domains',
    title: 'Official domains',
    paragraphs: ['Use only these official CryPrice domains:'],
    list: ['https://cryprice.dev', 'https://app.cryprice.dev', 'https://api.cryprice.dev'],
  },
] as const
