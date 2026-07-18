import { LINKS, ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const DOCS_META = {
  title: 'Documentation — CryPrice',
  description:
    'CryPrice documentation hub: security model, supported protocols, FAQ, API overview, and public engineering resources.',
  path: ROUTES.docs,
  lastUpdated: 'June 29, 2026',
} as const

export const DOCS_SUMMARY =
  'This page links to the main CryPrice documentation surfaces on cryprice.dev and public repositories. Use it to understand the read-only product model, supported scope, and where to find engineering references.'

export const DOCS_SECTIONS: readonly InfoSection[] = [
  {
    id: 'product-docs',
    title: 'Product documentation',
    paragraphs: ['Core product and trust documentation on this site:'],
    list: [
      `${ROUTES.security} — security model and responsible disclosure`,
      `${ROUTES.faq} — common questions about read-only monitoring`,
      `${ROUTES.supportedProtocols} — supported networks and DeFi protocols`,
      `${ROUTES.about} — project overview and official domains`,
      `${ROUTES.privacy} — privacy policy`,
      `${ROUTES.terms} — terms of service`,
      `${ROUTES.cookies} — cookie policy`,
      `${ROUTES.changelog} — product changelog`,
      `${ROUTES.status} — service status overview`,
    ],
  },
  {
    id: 'application',
    title: 'Application',
    paragraphs: [
      'The authenticated product dashboard is available at app.cryprice.dev. Account access is separate from wallet access.',
    ],
  },
  {
    id: 'api',
    title: 'API overview',
    paragraphs: [
      'The public API host is api.cryprice.dev. Portfolio and risk endpoints require authenticated sessions for user-specific data. A machine-readable API overview is available at the API root URL.',
      'Public engineering documentation and source trees are published on GitHub.',
    ],
    list: [
      LINKS.monoRepo,
      LINKS.webAppPath,
      LINKS.backendPath,
    ],
  },
] as const
