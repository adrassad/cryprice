import { FAQ_ITEMS } from '../content/faqContent'
import { AUTHOR, CONTACT, HOME_META, LINKS } from '../siteContent'
import { OG_IMAGE, SITE_ORIGIN } from './siteSeo'

const ORGANIZATION_ID = `${SITE_ORIGIN}/#organization`
const WEBSITE_ID = `${SITE_ORIGIN}/#website`
const PERSON_ID = `${SITE_ORIGIN}/#founder`
const WEB_APP_ID = 'https://app.cryprice.dev/#app'
const SUPPORT_CONTACT_ID = `${SITE_ORIGIN}/#contact-support`
const SECURITY_CONTACT_ID = `${SITE_ORIGIN}/#contact-security`

export function buildSiteStructuredDataGraph() {
  return [
    {
      '@type': 'WebSite',
      '@id': WEBSITE_ID,
      name: 'CryPrice',
      url: SITE_ORIGIN,
      description: HOME_META.description,
      inLanguage: 'en',
      publisher: { '@id': ORGANIZATION_ID },
    },
    {
      '@type': 'Organization',
      '@id': ORGANIZATION_ID,
      name: 'CryPrice',
      url: SITE_ORIGIN,
      email: CONTACT.supportEmail,
      description: 'Read-only DeFi risk intelligence and public address monitoring.',
      founder: { '@id': PERSON_ID },
      contactPoint: [
        { '@id': SUPPORT_CONTACT_ID },
        { '@id': SECURITY_CONTACT_ID },
      ],
      sameAs: [
        LINKS.monoRepo,
        LINKS.githubProfile,
        LINKS.xProfile,
        LINKS.telegram,
        LINKS.linkedIn,
      ],
    },
    {
      '@type': 'Person',
      '@id': PERSON_ID,
      name: AUTHOR.name,
      url: LINKS.githubProfile,
      jobTitle: 'Backend / Web3 developer',
      worksFor: { '@id': ORGANIZATION_ID },
      sameAs: [LINKS.githubProfile, LINKS.xProfile, LINKS.telegram, LINKS.linkedIn],
    },
    {
      '@type': 'ContactPoint',
      '@id': SUPPORT_CONTACT_ID,
      contactType: 'customer support',
      email: CONTACT.supportEmail,
      url: `${SITE_ORIGIN}/contact/`,
      availableLanguage: ['English', 'Russian'],
    },
    {
      '@type': 'ContactPoint',
      '@id': SECURITY_CONTACT_ID,
      contactType: 'security',
      email: CONTACT.securityEmail,
      url: `${SITE_ORIGIN}/security/`,
      availableLanguage: ['English', 'Russian'],
    },
    {
      '@type': 'WebApplication',
      '@id': WEB_APP_ID,
      name: 'CryPrice Dashboard',
      url: 'https://app.cryprice.dev/',
      applicationCategory: 'FinanceApplication',
      operatingSystem: 'Web',
      description:
        'Read-only DeFi risk intelligence dashboard for public address monitoring, portfolio visibility, and Aave Health Factor context.',
      isAccessibleForFree: true,
      provider: { '@id': ORGANIZATION_ID },
      image: OG_IMAGE,
    },
  ]
}

export function buildFaqPageStructuredData() {
  return {
    '@type': 'FAQPage',
    '@id': `${SITE_ORIGIN}/faq/#faqpage`,
    mainEntity: FAQ_ITEMS.map((item) => ({
      '@type': 'Question',
      name: item.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: item.answer,
      },
    })),
  }
}
