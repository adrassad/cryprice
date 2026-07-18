import {
  ARCHITECTURE_SNAPSHOT,
  CONTACT,
  INFRASTRUCTURE_OVERVIEW,
  LINKS,
  ROUTES,
  TRUST_GUARANTEES,
} from '../siteContent'

export const TRUST_META = {
  title: 'Trust — CryPrice',
  description:
    'CryPrice trust hub for security researchers and reviewers: read-only architecture, no custody, responsible disclosure, infrastructure summary, and official contacts.',
  path: ROUTES.trust,
  lastUpdated: 'July 14, 2026',
} as const

export const TRUST_SUMMARY =
  'CryPrice is a read-only DeFi risk intelligence platform. This page consolidates trust signals for security researchers, antivirus vendors, and enterprise reviewers — including architecture guarantees, disclosure policy, and official contacts.'

export const TRUST_SECTIONS = [
  {
    id: 'read-only-architecture',
    title: 'Read-Only Architecture',
    paragraphs: [
      'CryPrice aggregates publicly available blockchain and DeFi protocol data for public addresses users choose to monitor. The platform displays analytics, optional notifications, and reports based on that data.',
      'CryPrice does not execute blockchain transactions, connect wallets, or take custody of assets.',
    ],
    list: [...TRUST_GUARANTEES],
  },
  {
    id: 'no-custody',
    title: 'No Custody · No Wallet Connection',
    paragraphs: [
      'Users add public addresses for monitoring only. CryPrice cannot move funds from monitored wallets because we do not possess signing authority or private keys.',
      'Google OAuth is used for CryPrice account access only — not wallet access. Telegram is optional for user-configured notifications.',
    ],
  },
  {
    id: 'data-sources',
    title: 'Data Sources',
    paragraphs: [
      'CryPrice reads public on-chain state and protocol data (for example Aave V3 positions) via blockchain RPC providers and protocol adapters. Market price data may come from CEX/DEX/off-chain feeds normalized by the backend.',
      'Displayed data may be delayed or incomplete due to upstream provider limits, chain conditions, or maintenance. CryPrice is informational software — not financial advice.',
    ],
  },
  {
    id: 'infrastructure',
    title: 'Infrastructure Summary',
    paragraphs: [
      'Public CryPrice surfaces are served over HTTPS. DNS is protected with DNSSEC where enabled. The marketing site and related static assets are delivered through Cloudflare CDN.',
      `${INFRASTRUCTURE_OVERVIEW.lead}`,
    ],
    list: INFRASTRUCTURE_OVERVIEW.flow.map((step) => step),
  },
  {
    id: 'technology-stack',
    title: 'Open-Source & Technology Stack',
    paragraphs: [
      `${ARCHITECTURE_SNAPSHOT.lead}`,
      `Public engineering repositories: ${LINKS.monoRepo}`,
    ],
    list: [
      'Flutter Web — portfolio dashboard',
      'Node.js + Express — read-only API and workers',
      'PostgreSQL — durable application state',
      'Redis — caching and queue infrastructure',
      'BullMQ — background job processing',
      'Cloudflare — CDN and edge delivery for public websites',
    ],
  },
  {
    id: 'privacy',
    title: 'Privacy',
    paragraphs: [
      `CryPrice processes public blockchain addresses for read-only monitoring plus account-access data (Google OAuth) and optional Telegram identifiers for notifications you configure.`,
      `See the Privacy Policy at https://cryprice.dev${ROUTES.privacy} and the Transparency page at ${CONTACT.transparencyUrl}.`,
    ],
  },
  {
    id: 'responsible-disclosure',
    title: 'Responsible Disclosure',
    paragraphs: [
      `Report security vulnerabilities to ${CONTACT.securityEmail} (${CONTACT.securityMailto}). Do not open public GitHub issues with exploit details before we have had a reasonable opportunity to investigate.`,
      `Full security model: ${CONTACT.securityPolicyUrl}`,
      `GitHub security policy: ${CONTACT.githubSecurityPolicyUrl}`,
    ],
  },
  {
    id: 'security-txt',
    title: 'security.txt',
    paragraphs: [
      `Machine-readable security contact metadata: ${CONTACT.securityTxtUrl}`,
      'Canonical security.txt is also published on api.cryprice.dev and app.cryprice.dev.',
    ],
  },
  {
    id: 'acknowledgments',
    title: 'Acknowledgments',
    paragraphs: [
      'CryPrice appreciates responsible security reports from researchers and vendors. We do not currently operate a public paid bug bounty program.',
      'With reporter permission, we may acknowledge good-faith disclosures on this page or via public release notes.',
    ],
  },
  {
    id: 'transparency',
    title: 'Transparency',
    paragraphs: [
      `Project status, funding context, and development principles: ${CONTACT.transparencyUrl}`,
      `General contact: ${CONTACT.contactPageUrl}`,
    ],
  },
  {
    id: 'contact',
    title: 'Contact Information',
    paragraphs: [
      `Security: ${CONTACT.securityEmail}`,
      `Support: ${CONTACT.supportEmail}`,
      `Privacy: ${CONTACT.privacyEmail}`,
      `Legal: ${CONTACT.legalEmail}`,
      `Founder: ${CONTACT.founderEmail}`,
      `GitHub: ${LINKS.monoRepo}`,
      `X: ${LINKS.xProfile}`,
      `Telegram: ${LINKS.telegram}`,
    ],
  },
] as const satisfies readonly import('../content/legal/types').LegalSection[]
