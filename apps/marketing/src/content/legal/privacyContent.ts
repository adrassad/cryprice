import { CONTACT, ROUTES } from '../../siteContent'
import type { LegalSection } from './types'

export const PRIVACY_META = {
  title: 'Privacy Policy — CryPrice',
  description:
    'CryPrice processes public blockchain addresses for read-only monitoring, plus Google OAuth account access data and optional Telegram notification identifiers. We never connect wallets, request seed phrases, private keys, signatures, transactions, or custody funds.',
  path: ROUTES.privacy,
  lastUpdated: 'May 29, 2026',
} as const

export const PRIVACY_SECTIONS: readonly LegalSection[] = [
  {
    id: 'read-only-monitoring-and-public-address-data',
    title: 'Read-only monitoring and public address data',
    paragraphs: [
      'CryPrice is a read-only DeFi risk intelligence project. We process public wallet addresses — public blockchain addresses you choose to monitor — so we can show portfolio visibility, Aave Health Factor context, protocol exposure, alerts, and reports.',
      'Public wallet addresses used only for read-only monitoring are not wallet connections. CryPrice does not connect to wallets, ask for seed phrases or private keys, request wallet signatures, execute transactions, or custody funds.',
      'Google OAuth is used only for CryPrice account access. Telegram identifiers are used only for optional notifications that you configure, such as Health Factor or price alerts.',
    ],
  },
  {
    id: 'introduction',
    title: 'Introduction',
    paragraphs: [
      'This Privacy Policy describes how CryPrice ("CryPrice," "we," "us," or "our") handles information when you visit cryprice.dev, use app.cryprice.dev, or interact with related services (collectively, the "Service").',
      'CryPrice is a read-only DeFi portfolio intelligence and risk monitoring platform. We do not custody user funds, do not connect wallets, do not ask for private keys or seed phrases, and do not sign transactions on your behalf.',
      'By using the Service, you acknowledge that you have read this Privacy Policy. If you do not agree, please do not use the Service.',
    ],
  },
  {
    id: 'information-we-collect',
    title: 'Information We Collect',
    paragraphs: [
      'Depending on how you use CryPrice, we may collect or process the following categories of information:',
    ],
    list: [
      'Account and account-access data when you use Google OAuth (for example, name, email address, profile identifier, and tokens provided by the identity provider).',
      'Public wallet addresses (public blockchain addresses) that you choose to add for read-only monitoring.',
      'Portfolio, DeFi position, and risk-related data derived from public blockchain and protocol sources for public addresses you track (for example, balances, Aave Health Factor, supplied and borrowed positions, and allocation views).',
      'Telegram identifiers and linking data if you link Telegram for optional notifications.',
      'Alert preferences and notification settings you configure in the app.',
      'Usage, diagnostic, and security logs (for example, IP address, browser or app metadata, request timestamps, error events, and security-related activity).',
      'Basic technical data on the marketing site (for example, page views and browser type) through standard web technologies described below.',
    ],
  },
  {
    id: 'how-we-use-information',
    title: 'How We Use Information',
    paragraphs: [
      'We use collected information to operate, maintain, and improve the Service. Typical uses include:',
    ],
    list: [
      'Authenticating users and maintaining account sessions.',
      'Aggregating read-only portfolio and DeFi risk data for public addresses you add.',
      'Calculating and displaying analytics such as allocation, Health Factor monitoring, and multi-chain views.',
      'Sending optional notifications you configure (for example, via Telegram).',
      'Generating server-side reports such as PDF portfolio exports when requested.',
      'Monitoring service health, preventing abuse, and investigating security incidents.',
      'Complying with applicable legal obligations where required.',
    ],
  },
  {
    id: 'wallet-and-blockchain-data',
    title: 'Wallet and Blockchain Data',
    paragraphs: [
      'CryPrice monitors public blockchain addresses only. We do not request, store, or process private keys, seed phrases, or wallet signatures.',
      'Blockchain data we process is generally public by nature. Adding a public blockchain address means you direct us to retrieve and display associated on-chain and protocol data for monitoring purposes.',
      'Wallet tracking is read-only. CryPrice does not initiate transactions, move funds, or act as a custodian.',
    ],
  },
  {
    id: 'google-oauth',
    title: 'Google OAuth',
    paragraphs: [
      'CryPrice may offer Google OAuth for CryPrice account access only. When you choose this option, Google may share certain profile information with us according to your Google account settings and Google\'s policies.',
      'We typically receive identifiers needed to operate your CryPrice account (such as email address, name, and a provider-specific user ID). We use this information to create and manage your CryPrice account, not for unrelated marketing purposes.',
      'Your use of Google account access is also subject to Google\'s privacy policy and terms. We do not receive your Google password.',
    ],
  },
  {
    id: 'telegram-alerts',
    title: 'Telegram Notifications',
    paragraphs: [
      'If you link Telegram for optional notifications, we may store Telegram-related identifiers and linking tokens needed to deliver notifications you configure (for example, Health Factor or price threshold updates).',
      'Telegram linking is optional. You can manage or remove linked alert channels through the app where those controls are available.',
      'Messages sent through Telegram are also subject to Telegram\'s own terms and privacy practices.',
    ],
  },
  {
    id: 'cookies-local-storage',
    title: 'Cookies / Local Storage',
    paragraphs: [
      'The marketing site and web app may use cookies, local storage, or similar browser technologies to support basic functionality, session management, preferences, and security.',
      'These technologies may store authentication state, UI preferences, or anti-abuse signals. You can control cookies through your browser settings, though disabling them may limit parts of the Service.',
      'We do not describe CryPrice as "cookie-free." Specific storage mechanisms may vary between the marketing site and the authenticated app.',
    ],
  },
  {
    id: 'data-sharing',
    title: 'Data Sharing',
    paragraphs: [
      'We do not sell your personal information. We may share information only in limited circumstances, such as:',
    ],
    list: [
      'With infrastructure and service providers that help us host, operate, secure, or deliver the Service (for example, cloud hosting, databases, caching, email or notification delivery), under appropriate confidentiality and security expectations.',
      'When required by law, regulation, legal process, or governmental request.',
      'To protect the rights, safety, and security of CryPrice, our users, or others, including investigating abuse or security incidents.',
      'In connection with a merger, acquisition, restructuring, or sale of assets, subject to applicable law.',
    ],
  },
  {
    id: 'security',
    title: 'Security',
    paragraphs: [
      'We apply reasonable technical and organizational measures designed to protect information we process, including access controls, encrypted transport where appropriate, and monitoring for abuse.',
      'No method of transmission or storage is completely secure. We cannot guarantee absolute security, and you use the Service at your own risk with respect to security incidents outside our reasonable control.',
      'Because CryPrice is read-only and does not custody funds or private keys, a compromise of monitoring data is different in impact from custody of signing keys — but you should still protect your accounts and devices.',
    ],
  },
  {
    id: 'data-retention',
    title: 'Data Retention',
    paragraphs: [
      'We retain information for as long as reasonably necessary to provide the Service, maintain records, comply with legal obligations, resolve disputes, and enforce agreements.',
      'Retention periods may vary by data type. For example, account data may be kept while your account is active; security logs may be retained for a defined operational period; public address monitoring data may persist until you remove an address or delete your account, subject to backup and legal constraints.',
      'We may retain anonymized or aggregated data that no longer identifies you.',
    ],
  },
  {
    id: 'your-choices',
    title: 'Your Choices',
    paragraphs: [
      'Depending on the features available in the app, you may be able to:',
    ],
    list: [
      'Review or update account-related information in your profile.',
      'Add or remove public addresses from monitoring.',
      'Configure, disable, or unlink optional Telegram notifications.',
      'Sign out and limit active sessions.',
      'Contact us to request information about your data or to ask questions about this policy.',
    ],
    paragraphsAfterList: [
      'If you are located in a region with specific privacy rights (for example, access, correction, or deletion rights), contact us using the details below. We will respond as required by applicable law.',
    ],
  },
  {
    id: 'no-financial-advice',
    title: 'No Financial Advice',
    paragraphs: [
      'CryPrice provides informational and monitoring tools only. We do not provide investment, tax, legal, or financial advice.',
      'Cryptocurrency and DeFi activity involves substantial risk, including smart contract risk, liquidation risk, market volatility, and regulatory uncertainty. You are solely responsible for your financial decisions.',
    ],
  },
  {
    id: 'contact',
    title: 'Contact',
    paragraphs: [
      `For privacy-related questions about this policy, email ${CONTACT.privacyEmail} (${CONTACT.privacyMailto}).`,
      `For security vulnerability reports, email ${CONTACT.securityEmail} or see ${CONTACT.securityTxtUrl}.`,
    ],
  },
  {
    id: 'last-updated',
    title: 'Last Updated',
    paragraphs: [`This Privacy Policy was last updated on ${PRIVACY_META.lastUpdated}.`],
  },
] as const
