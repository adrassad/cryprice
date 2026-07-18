import { ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const CHANGELOG_META = {
  title: 'Changelog — CryPrice',
  description:
    'CryPrice product changelog: notable releases and improvements to the read-only DeFi monitoring platform.',
  path: ROUTES.changelog,
  lastUpdated: 'June 29, 2026',
} as const

export const CHANGELOG_SUMMARY =
  'This changelog summarizes notable public product and website updates. It is not an exhaustive commit log; engineering history remains available in the public GitHub repository.'

export const CHANGELOG_SECTIONS: readonly InfoSection[] = [
  {
    id: '2026-06',
    title: 'June 2026',
    paragraphs: ['Recent public-facing updates include:'],
    list: [
      'Expanded marketing trust pages: About, Documentation, Supported Protocols, Cookie Policy, Changelog, and Status',
      'Improved SEO and structured data across cryprice.dev',
      'Prerendered legal, FAQ, and contact pages for crawler-visible content',
    ],
  },
  {
    id: '2026-05',
    title: 'May 2026',
    paragraphs: ['Earlier platform milestones include:'],
    list: [
      'Aave V3 Health Factor monitoring and threshold alerts',
      'Multi-address portfolio dashboard on app.cryprice.dev',
      'Optional notification linking after account access setup',
      'Server-side PDF portfolio export',
    ],
  },
  {
    id: 'roadmap',
    title: 'What is next',
    paragraphs: [
      'See the public roadmap on the home page for planned capabilities such as Risk Insights, additional protocol adapters, historical analytics, and export formats.',
      `Current supported scope is documented on ${ROUTES.supportedProtocols}.`,
    ],
  },
] as const
