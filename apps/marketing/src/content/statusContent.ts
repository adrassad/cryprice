import { LINKS, ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const STATUS_META = {
  title: 'Status — CryPrice',
  description:
    'CryPrice service status overview for cryprice.dev, app.cryprice.dev, and api.cryprice.dev.',
  path: ROUTES.status,
  lastUpdated: 'June 29, 2026',
} as const

export const STATUS_SUMMARY =
  'This page provides a lightweight public status overview for CryPrice surfaces. It is not a real-time incident dashboard; for urgent security reports use the contact channels listed on the security page.'

export const STATUS_SECTIONS: readonly InfoSection[] = [
  {
    id: 'current-status',
    title: 'Current status',
    paragraphs: ['As of the last update on this page, the public CryPrice surfaces are expected to be available:'],
    list: [
      'cryprice.dev — marketing site and documentation',
      'app.cryprice.dev — authenticated web dashboard',
      'api.cryprice.dev — read-only backend API',
    ],
    paragraphsAfterList: [
      'Temporary outages may occur during maintenance, upstream provider issues, or network disruptions. Data freshness can vary by chain, protocol, and provider.',
    ],
  },
  {
    id: 'dependencies',
    title: 'External dependencies',
    paragraphs: [
      'CryPrice depends on blockchain nodes, DeFi protocol data sources, market data providers, cloud infrastructure, Google account access, and optional notification channels. Issues outside CryPrice infrastructure may affect data accuracy or alert delivery.',
    ],
  },
  {
    id: 'reporting',
    title: 'Report an issue',
    paragraphs: [
      'For security vulnerabilities, use the responsible disclosure process documented on the security page.',
      'For general product inquiries, use the contact page or email listed in the footer.',
    ],
    list: [
      ROUTES.security,
      ROUTES.contact,
      LINKS.monoRepo,
    ],
  },
] as const
