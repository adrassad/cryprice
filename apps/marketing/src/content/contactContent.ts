import { AUTHOR, CONTACT, LINKS, ROUTES } from '../siteContent'

export const CONTACT_META = {
  title: 'Contact — CryPrice',
  description:
    'Contact CryPrice for support, security reports, privacy, legal, and press inquiries. Read-only DeFi risk intelligence — public address monitoring only.',
  path: ROUTES.contact,
  lastUpdated: 'July 14, 2026',
} as const

export const CONTACT_INTRO =
  'CryPrice is a founder-led, independent read-only DeFi risk intelligence project built in public by Andrei Sharapov. Use the channels below or the contact form for support, security, privacy, legal, press, or general project inquiries.'

export const CONTACT_CHANNELS = [
  {
    label: 'General Support',
    value: CONTACT.supportEmail,
    href: CONTACT.supportMailto,
  },
  {
    label: 'Security',
    value: CONTACT.securityEmail,
    href: CONTACT.securityMailto,
  },
  {
    label: 'Privacy',
    value: CONTACT.privacyEmail,
    href: CONTACT.privacyMailto,
  },
  {
    label: 'Legal',
    value: CONTACT.legalEmail,
    href: CONTACT.legalMailto,
  },
  {
    label: 'Founder',
    value: CONTACT.founderEmail,
    href: CONTACT.founderMailto,
  },
  {
    label: 'Press',
    value: CONTACT.pressEmail,
    href: CONTACT.pressMailto,
  },
] as const

export const CONTACT_SOCIAL = [
  {
    label: 'GitHub',
    value: 'github.com/adrassad/cryprice',
    href: LINKS.monoRepo,
    external: true,
  },
  {
    label: 'X (public notes)',
    value: AUTHOR.xHandle,
    href: LINKS.xProfile,
    external: true,
  },
  {
    label: 'Telegram',
    value: '@adrassad',
    href: LINKS.telegram,
    external: true,
  },
] as const

export const CONTACT_DETAILS = [
  {
    label: 'Project',
    value: 'CryPrice',
  },
  {
    label: 'Purpose',
    value: 'Read-only DeFi risk intelligence and public address monitoring',
  },
  {
    label: 'Website',
    value: 'https://cryprice.dev',
    href: 'https://cryprice.dev/',
  },
  ...CONTACT_CHANNELS,
  ...CONTACT_SOCIAL,
  {
    label: 'Founder / Builder',
    value: AUTHOR.name,
  },
  {
    label: 'Role',
    value: 'Backend / Web3 developer · DeFi risk monitoring',
  },
] as const

export const CONTACT_RELATED_LINKS = [
  { label: 'About', path: ROUTES.about },
  { label: 'Trust', path: ROUTES.trust },
  { label: 'Transparency', path: ROUTES.transparency },
  { label: 'Documentation', path: ROUTES.docs },
  { label: 'Security Model', path: ROUTES.security },
  { label: 'FAQ', path: ROUTES.faq },
  { label: 'Privacy Policy', path: ROUTES.privacy },
  { label: 'Terms of Service', path: ROUTES.terms },
] as const

export const CONTACT_FORM_TOPICS = [
  { value: 'support', label: 'General Support' },
  { value: 'security', label: 'Security' },
  { value: 'privacy', label: 'Privacy' },
  { value: 'legal', label: 'Legal' },
  { value: 'press', label: 'Press' },
  { value: 'other', label: 'Other' },
] as const
