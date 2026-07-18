import { CONTACT, ROUTES } from '../../siteContent'

export const SECURITY_TXT_URL = CONTACT.securityTxtUrl
export const SECURITY_POLICY_URL = CONTACT.securityPolicyUrl

export const SECURITY_META = {
  title: 'Security — CryPrice',
  description:
    'How CryPrice approaches security: read-only DeFi monitoring, no wallet connection, no private key access, public address safety guidance, Google account access, optional Telegram notifications, and responsible vulnerability disclosure.',
  path: ROUTES.security,
  lastUpdated: 'July 14, 2026',
} as const

export const SECURITY_SECTIONS = [
  {
    id: 'overview',
    title: 'Security Overview',
    paragraphs: [
      'CryPrice is a read-only DeFi portfolio intelligence and risk monitoring platform. Our security model is built around observation — not custody, wallet connection, signing, or control of your assets.',
      'We design the Service to help you monitor public addresses, Aave Health Factor, protocol exposure, and related risk signals across supported networks. CryPrice is informational software; it is not a wallet, exchange, custodian, or transaction relayer.',
      'This page describes our security posture, your responsibilities, and how to report security concerns. It is not a guarantee of perfect security or uninterrupted service.',
    ],
  },
  {
    id: 'read-only-architecture',
    title: 'Read-Only Architecture',
    paragraphs: [
      'CryPrice operates as a read-only monitoring stack. The backend aggregates publicly available blockchain and protocol data for public addresses you choose to add. The Service displays analytics, optional notifications, and reports based on that data.',
      'CryPrice does not execute blockchain transactions on your behalf. We do not submit swaps, transfers, borrows, repays, or approvals. Monitoring and alerting are informational — any on-chain action you take remains outside CryPrice and under your direct control.',
      'Because the platform is read-only, a compromise of CryPrice monitoring data is materially different from compromise of a service that holds private keys or custodied funds — though you should still treat account and alert configuration as sensitive.',
    ],
  },
  {
    id: 'public-address-safety',
    title: 'Public Address Safety',
    paragraphs: [
      'You remain solely responsible for the security of your wallets and any protocols you interact with. CryPrice displays data for public addresses you submit; it does not verify ownership beyond the account-access and configuration flows provided in the product.',
      'Only add public addresses you intend to monitor and have a lawful basis to track. Review displayed balances, Health Factor readings, and notifications critically — blockchain data can be delayed, incomplete, or affected by upstream provider issues.',
      'CryPrice cannot prevent phishing, social engineering, malicious browser extensions, compromised devices, or unauthorized use of your external wallets. Protect your devices, browsers, and wallet software independently of CryPrice.',
    ],
  },
  {
    id: 'no-private-key-access',
    title: 'No Private Key Access',
    paragraphs: [
      'CryPrice never asks for seed phrases, private keys, keystore files, or wallet signing credentials. We will not request them via the app, email, Telegram, social media, or support channels.',
      'If anyone claiming to represent CryPrice asks for your seed phrase or private key, treat it as fraud and do not share it. Legitimate CryPrice operation does not require these secrets.',
      'Wallet tracking uses public addresses only. CryPrice cannot move funds from monitored wallets because we do not possess signing authority.',
    ],
  },
  {
    id: 'google-oauth-security',
    title: 'Google OAuth Security',
    paragraphs: [
      'CryPrice may offer Google OAuth for CryPrice account access only. When you use Google account access this way, Google handles primary authentication according to its own security practices and your Google account settings.',
      'We receive identifiers needed to operate your CryPrice account — such as email address, name, and a provider-specific user ID — not your Google password. Protect your Google account with strong credentials and, where available, multi-factor authentication.',
      `If you suspect unauthorized access to your CryPrice account via Google account access, revoke CryPrice access in your Google account security settings and contact us at ${CONTACT.securityEmail}.`,
    ],
  },
  {
    id: 'telegram-notification-security',
    title: 'Telegram Notification Security',
    paragraphs: [
      'Telegram linking is optional and used to deliver notifications you configure — for example, Health Factor or price threshold updates. Linking is performed through account-access flows in the CryPrice product.',
      'Telegram messages may contain portfolio or risk-related information. Treat your linked Telegram account and devices as sensitive. Do not share alert messages in public channels if they reveal financial information you wish to keep private.',
      'Telegram operates under its own terms and security model. CryPrice is not responsible for Telegram outages, account compromises, or message delivery failures outside our reasonable control.',
    ],
  },
  {
    id: 'infrastructure-security',
    title: 'Infrastructure Security',
    paragraphs: [
      'We apply reasonable technical and organizational measures intended to protect the Service and the data we process, which may include encrypted transport (HTTPS/TLS), access controls, logging, and monitoring for abuse.',
      'Public CryPrice websites are delivered through Cloudflare CDN. DNS is protected with DNSSEC where enabled. Our stack includes web frontends, backend APIs, databases, caching layers, background workers (including BullMQ job processing), and integrations with blockchain data sources and notification providers.',
      'We aim to follow common secure development and deployment practices, but no system is immune to vulnerability or misconfiguration. We do not describe CryPrice as "unhackable" or perfectly secure. Security is an ongoing process, not a fixed state.',
      `For a consolidated trust hub aimed at researchers and vendors, see ${CONTACT.trustUrl}.`,
    ],
  },
  {
    id: 'vulnerability-disclosure-policy',
    title: 'Vulnerability Disclosure Policy',
    paragraphs: [
      'This policy applies to good-faith security research on CryPrice public surfaces: cryprice.dev, app.cryprice.dev, api.cryprice.dev, and related public repositories documented on this site.',
      'In scope: vulnerabilities that affect confidentiality, integrity, or availability of CryPrice public services or user data handled by those services.',
      'Out of scope: social engineering, physical attacks, denial-of-service attacks, issues in third-party services outside our control, and findings that require access to other users\' private data beyond what is necessary to demonstrate impact.',
      `Report in scope issues to ${CONTACT.securityEmail}. For machine-readable metadata see ${CONTACT.securityTxtUrl}.`,
    ],
  },
  {
    id: 'expected-response-times',
    title: 'Expected Response Times',
    paragraphs: [
      'We aim to acknowledge credible security reports within 3 business days when contact details are provided.',
      'We aim to provide an initial triage assessment within 10 business days for verified reports that include enough detail to investigate.',
      'Complex issues may require more time. We will communicate status updates when feasible. These timelines are targets — not guarantees of resolution or compensation.',
    ],
  },
  {
    id: 'responsible-disclosure',
    title: 'Responsible Disclosure',
    paragraphs: [
      'We welcome good-faith reports of security vulnerabilities affecting CryPrice public websites, applications, and documented public API surfaces. Responsible disclosure helps us investigate and address issues before they are widely exploited.',
      `Report security issues to ${CONTACT.securityEmail} (${CONTACT.securityMailto}). Do not open public GitHub issues or post vulnerability details on social media before we have had a reasonable opportunity to investigate.`,
      `Our machine-readable security contact file is published at ${CONTACT.securityTxtUrl}. Additional reporting guidance is available in our public GitHub security policy: ${CONTACT.githubSecurityPolicyUrl}.`,
      `Trust hub for researchers: ${CONTACT.trustUrl} · Project transparency: ${CONTACT.transparencyUrl}`,
    ],
  },
  {
    id: 'reporting-security-issues',
    title: 'Reporting Security Issues',
    paragraphs: [
      `Email ${CONTACT.securityEmail} if you believe you have discovered a security issue. We will acknowledge receipt when feasible and work to investigate credible reports.`,
      'Please include the following in your report:',
    ],
    list: [
      'A clear description of the vulnerability or concern',
      'Affected URLs, domains, or components (for example, cryprice.dev, app.cryprice.dev, or api.cryprice.dev)',
      'Steps to reproduce the issue, if applicable',
      'Your assessment of potential impact',
      'Your contact information for follow-up (optional, but helpful)',
    ],
    paragraphsAfterList: [
      'CryPrice does not currently operate a public paid bug bounty program, but responsible security reports are welcome and appreciated. We cannot guarantee compensation for reports.',
      `For policy scope, out-of-scope items, and additional guidance, see ${CONTACT.githubSecurityPolicyUrl}.`,
    ],
  },
  {
    id: 'testing-guidelines',
    title: 'Testing Guidelines',
    paragraphs: ['When testing CryPrice systems, please do not:'],
    list: [
      'Access, modify, or exfiltrate data belonging to other users',
      'Perform denial-of-service attacks or actions that degrade service availability',
      'Use automated scanning in ways that could disrupt production services',
      'Exploit vulnerabilities beyond what is necessary to demonstrate impact',
      'Violate applicable laws or third-party terms of service',
      'Publicly disclose issue details before we have had a reasonable opportunity to investigate and respond',
    ],
    paragraphsAfterList: [
      `If you are unsure whether a test is appropriate, contact us at ${CONTACT.securityEmail} before proceeding.`,
    ],
  },
  {
    id: 'safe-usage-recommendations',
    title: 'Safe Usage Recommendations',
    paragraphs: ['To use CryPrice more safely, we recommend:'],
    list: [
      'Never share seed phrases, private keys, or wallet backup files with anyone — including anyone claiming to be CryPrice support.',
      'Verify you are on official CryPrice domains (cryprice.dev, app.cryprice.dev) before using account access.',
      'Use strong, unique credentials for Google and enable multi-factor authentication where available.',
      'Review wallet addresses you add for monitoring and remove addresses you no longer wish to track.',
      'Treat Telegram and email alert channels as sensitive notification paths.',
      'Keep your browser, operating system, and wallet software updated.',
      'Understand that DeFi monitoring data is informational and may not reflect real-time on-chain conditions.',
    ],
  },
  {
    id: 'third-party-dependencies',
    title: 'Third-Party Dependencies',
    paragraphs: [
      'CryPrice relies on third-party services and infrastructure, which may include Google OAuth, Telegram, cloud hosting providers, blockchain nodes, DeFi protocol data sources, and market data feeds.',
      'We do not control the security, availability, or policies of these third parties. Outages, data delays, or security incidents at upstream providers may affect CryPrice functionality or data accuracy.',
      'Your use of linked third-party accounts remains subject to their respective terms and privacy policies.',
    ],
  },
  {
    id: 'availability-disclaimer',
    title: 'Availability Disclaimer',
    paragraphs: [
      'We aim to keep CryPrice available and data reasonably current, but we do not guarantee uninterrupted uptime, real-time accuracy, or error-free alert delivery.',
      'Maintenance windows, upstream provider failures, chain reorganizations, API rate limits, and network conditions may delay data sync or notifications. Do not rely on CryPrice as your only liquidation or risk warning system.',
      'For terms governing use of the Service, see our Terms of Service. For data handling practices, see our Privacy Policy.',
    ],
    paragraphsAfterList: [
      `Terms of Service: ${ROUTES.terms} · Privacy Policy: ${ROUTES.privacy}`,
    ],
  },
  {
    id: 'contact',
    title: 'Contact Information',
    paragraphs: [
      `General support: ${CONTACT.supportEmail} (${CONTACT.supportMailto})`,
      `Security reports: ${CONTACT.securityEmail} (${CONTACT.securityMailto})`,
      `Security policy page: ${CONTACT.securityPolicyUrl}`,
      `Trust hub: ${CONTACT.trustUrl}`,
      `Transparency: ${CONTACT.transparencyUrl}`,
      `Machine-readable contact file: ${CONTACT.securityTxtUrl}`,
      `GitHub security policy: ${CONTACT.githubSecurityPolicyUrl}`,
      `Public updates may also be posted on X: ${CONTACT.xProfile}.`,
    ],
  },
  {
    id: 'last-updated',
    title: 'Last Updated',
    paragraphs: [`This Security page was last updated on ${SECURITY_META.lastUpdated}.`],
  },
] as const satisfies readonly import('./types').LegalSection[]

export const SECURITY_SUMMARY =
  `CryPrice is a read-only DeFi monitoring tool. CryPrice monitors public blockchain addresses only, does not connect to wallets, never asks for seed phrases or private keys, does not sign transactions, and does not custody funds. Google OAuth is used only for account access; Telegram is used only for optional notifications. CryPrice does not provide financial advice. Report security issues to ${CONTACT.securityEmail}. This page explains our security approach, your responsibilities, and how to report issues responsibly.`
