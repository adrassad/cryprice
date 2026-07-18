import { CONTACT, ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const COOKIES_META = {
  title: 'Cookie Policy — CryPrice',
  description:
    'How CryPrice uses cookies, local storage, and similar browser technologies on cryprice.dev and app.cryprice.dev.',
  path: ROUTES.cookies,
  lastUpdated: 'June 29, 2026',
} as const

export const COOKIES_SUMMARY =
  'This Cookie Policy explains how CryPrice may use cookies, local storage, and similar technologies on the marketing website and web application. CryPrice is not marketed as cookie-free; specific storage mechanisms may differ between the marketing site and the authenticated app.'

export const COOKIES_SECTIONS: readonly InfoSection[] = [
  {
    id: 'overview',
    title: 'Overview',
    paragraphs: [
      'Cookies and similar technologies help us provide basic site functionality, maintain sessions, remember preferences, and protect the Service from abuse.',
      'By continuing to use cryprice.dev or app.cryprice.dev, you acknowledge this policy alongside our Privacy Policy.',
    ],
  },
  {
    id: 'marketing-site',
    title: 'Marketing site (cryprice.dev)',
    paragraphs: ['On the marketing website, technologies may be used for:'],
    list: [
      'basic navigation and page rendering',
      'remembering lightweight UI preferences where applicable',
      'security and anti-abuse signals at the CDN or hosting layer',
    ],
  },
  {
    id: 'web-app',
    title: 'Web application (app.cryprice.dev)',
    paragraphs: ['In the authenticated web app, technologies may be used for:'],
    list: [
      'account session and authentication state',
      'UI preferences such as theme or locale',
      'application update and service worker behavior where enabled',
    ],
  },
  {
    id: 'third-party',
    title: 'Third-party technologies',
    paragraphs: [
      'When you use Google for CryPrice account access, Google may set or read cookies according to its own policies. CryPrice does not control third-party cookie behavior.',
    ],
  },
  {
    id: 'your-choices',
    title: 'Your choices',
    paragraphs: [
      'You can control cookies through your browser settings. Disabling cookies or local storage may limit parts of the Service, especially authenticated dashboard features.',
      `For privacy questions, contact ${CONTACT.publicContactEmail}. See also ${ROUTES.privacy}.`,
    ],
  },
] as const
