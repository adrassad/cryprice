import { AUTHOR, CONTACT, LINKS, PUBLIC_WORK, ROUTES } from '../siteContent'

export const TRANSPARENCY_META = {
  title: 'Transparency — CryPrice',
  description:
    'CryPrice project transparency: independent pre-incorporation startup, founder-led development, business model, goals, public channels, and development principles.',
  path: ROUTES.transparency,
  lastUpdated: 'July 14, 2026',
} as const

export const TRANSPARENCY_SUMMARY =
  'CryPrice is an independent, founder-led crypto risk intelligence project in active development. This page explains our current status, how the project is built and funded, and where to find official information — without overstating legal or corporate claims.'

export const TRANSPARENCY_SECTIONS = [
  {
    id: 'current-status',
    title: 'Current Status',
    paragraphs: [
      'CryPrice is a working read-only DeFi risk monitoring product with public marketing site (cryprice.dev), authenticated web dashboard (app.cryprice.dev), and read-only API (api.cryprice.dev).',
      'The platform currently focuses on multi-address portfolio visibility and Aave V3 Health Factor monitoring across Ethereum, Arbitrum, Avalanche, and Base.',
    ],
  },
  {
    id: 'independent-startup',
    title: 'Independent Startup · Pre-Incorporation',
    paragraphs: [
      'CryPrice is an independent startup project led by Andrei Sharapov. There is no registered legal entity yet — CryPrice is pre-incorporation.',
      'We do not publish a company registration number, VAT ID, or corporate registered address because none exists at this stage. Official project identity is the CryPrice brand and the official domains listed on this site.',
    ],
  },
  {
    id: 'funding-status',
    title: 'Funding Status',
    paragraphs: [
      'CryPrice is founder-funded and built in public. We do not claim institutional backing, grants, or partnerships unless explicitly announced through official channels.',
      'Investment materials may be available to qualified parties on request — contact founder@cryprice.dev for diligence context appropriate to your review.',
    ],
  },
  {
    id: 'business-model',
    title: 'Business Model',
    paragraphs: [
      'CryPrice is developing a read-only DeFi risk intelligence platform. The intended model is subscription access to monitoring, alerting, and portfolio intelligence features for DeFi users who manage borrowing and lending risk.',
      'Pricing tiers and commercial packaging may evolve as the product matures. Current public documentation describes capabilities — not a binding commercial offer.',
    ],
  },
  {
    id: 'project-goals',
    title: 'Project Goals',
    paragraphs: [
      'Make DeFi borrowing and lending risk easier to observe before market stress turns into forced liquidations.',
      'Provide a single read-only monitoring layer across public addresses, protocols, and networks — without custody, wallet connection, or on-chain execution.',
      'Expand protocol coverage and human-readable risk insights over time while preserving a read-only security model.',
    ],
  },
  {
    id: 'roadmap',
    title: 'Roadmap',
    paragraphs: [
      'Planned capabilities are published on the CryPrice homepage Roadmap section. Items listed there are planned — not all are live in the product yet.',
      'See the homepage Roadmap: https://cryprice.dev/#roadmap',
    ],
  },
  {
    id: 'founder',
    title: 'Founder',
    paragraphs: [
      `${AUTHOR.body}`,
      `Contact: ${CONTACT.founderEmail}`,
    ],
  },
  {
    id: 'public-channels',
    title: 'Public Communication Channels',
    paragraphs: [PUBLIC_WORK.lead],
    list: [
      `GitHub engineering: ${LINKS.monoRepo}`,
      `GitHub profile: ${LINKS.githubProfile}`,
      `X (public notes): ${LINKS.xProfile}`,
      `Telegram: ${LINKS.telegram}`,
    ],
  },
  {
    id: 'development-principles',
    title: 'Development Principles',
    paragraphs: ['CryPrice development follows these principles:'],
    list: [
      'Read-only by design — no private key custody or transaction execution',
      'Backend-owned aggregation for portfolio and risk views',
      'Truthful public documentation — no invented legal entity or certifications',
      'Responsible disclosure for security issues',
      'Open engineering visibility via public repositories where applicable',
    ],
  },
  {
    id: 'faq',
    title: 'FAQ',
    paragraphs: [
      `Common questions about wallet connection, seed phrases, private keys, and data handling: ${ROUTES.faq}`,
      `Trust & security hub for researchers: ${ROUTES.trust}`,
    ],
  },
  {
    id: 'contact',
    title: 'Contact',
    paragraphs: [
      `Support: ${CONTACT.supportEmail}`,
      `Security: ${CONTACT.securityEmail}`,
      `Privacy: ${CONTACT.privacyEmail}`,
      `Legal: ${CONTACT.legalEmail}`,
      `Press: ${CONTACT.pressEmail}`,
      `Founder: ${CONTACT.founderEmail}`,
      `Contact page: ${CONTACT.contactPageUrl}`,
    ],
  },
] as const satisfies readonly import('../content/legal/types').LegalSection[]
