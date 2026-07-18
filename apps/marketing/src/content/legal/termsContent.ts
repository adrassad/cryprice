import { CONTACT, ROUTES } from '../../siteContent'
import type { LegalSection } from './types'

export const TERMS_META = {
  title: 'Terms of Service — CryPrice',
  description:
    'Terms governing use of CryPrice, a read-only DeFi portfolio intelligence and risk monitoring platform. No custody, no transaction signing, informational use only.',
  path: ROUTES.terms,
  lastUpdated: 'May 29, 2026',
} as const

export const TERMS_SECTIONS: readonly LegalSection[] = [
  {
    id: 'acceptance',
    title: 'Acceptance of Terms',
    paragraphs: [
      'These Terms of Service ("Terms") govern your access to and use of CryPrice websites, applications, APIs, and related services (collectively, the "Service") operated by CryPrice ("we," "us," or "our").',
      'By accessing or using the Service, you agree to these Terms. If you do not agree, do not use the Service.',
      'We may update these Terms from time to time. Continued use after changes become effective constitutes acceptance of the revised Terms, to the extent permitted by applicable law.',
    ],
  },
  {
    id: 'description-of-service',
    title: 'Description of Service',
    paragraphs: [
      'CryPrice provides read-only DeFi portfolio intelligence and risk monitoring tools. Features may include multi-chain public address monitoring, Aave Health Factor tracking, protocol exposure views, allocation analytics, optional Telegram notifications, PDF reports, and related informational dashboards.',
      'The Service is designed to help users observe and analyze publicly available blockchain and protocol data for public addresses they choose to track. CryPrice is informational software — not a wallet, exchange, broker, custodian, or transaction execution service.',
    ],
  },
  {
    id: 'read-only',
    title: 'Read-Only Nature of Platform',
    paragraphs: [
      'CryPrice does not custody user funds. We never ask for seed phrases or private keys, do not connect wallets, and do not sign blockchain transactions on your behalf.',
      'Monitoring is read-only. You add public addresses for tracking; CryPrice retrieves and displays associated data from public sources. We do not move assets, approve transactions, or act as your agent on-chain.',
      'Any actions you take with your wallets or DeFi protocols outside CryPrice remain solely your responsibility.',
    ],
  },
  {
    id: 'no-financial-advice',
    title: 'No Financial Advice',
    paragraphs: [
      'CryPrice does not provide investment, trading, tax, legal, or financial advice. All information, metrics, alerts, reports, and analytics are provided for general informational purposes only.',
      'You should not rely on the Service as the sole basis for financial decisions. Consult qualified professionals before making decisions involving digital assets or DeFi protocols.',
    ],
  },
  {
    id: 'user-responsibilities',
    title: 'User Responsibilities',
    paragraphs: ['You agree that you are responsible for:'],
    list: [
      'Maintaining the security of your accounts, devices, and third-party credentials (including Google or Telegram accounts you link for optional notifications).',
      'Ensuring public addresses you add are correct and that you have a lawful basis to monitor them.',
      'Evaluating the accuracy and completeness of displayed data before acting on it.',
      'Your own on-chain and protocol interactions, including borrows, supplies, swaps, and liquidations.',
      'Compliance with applicable laws and regulations in your jurisdiction.',
      'Using the Service in a lawful manner and not attempting to disrupt, abuse, or reverse engineer it.',
    ],
  },
  {
    id: 'third-party-services',
    title: 'Third-Party Services',
    paragraphs: [
      'CryPrice may integrate with or rely on third-party services such as Google OAuth for account access, Telegram for optional notifications, cloud infrastructure providers, blockchain nodes, and DeFi protocol data sources.',
      'Your use of third-party services is subject to their own terms and privacy policies. We do not control and are not responsible for third-party services, their availability, or their actions.',
      'Links to external sites or repositories are provided for convenience and do not constitute endorsement.',
    ],
  },
  {
    id: 'blockchain-defi-risks',
    title: 'Blockchain and DeFi Risks',
    paragraphs: [
      'Cryptocurrency, blockchain networks, and DeFi protocols involve significant risks, including but not limited to smart contract vulnerabilities, oracle failures, liquidation events, impermanent loss, bridge failures, regulatory changes, and total loss of value.',
      'Blockchain data may be delayed, incomplete, or inaccurate. Health Factor readings, balances, prices, and alerts may not reflect real-time conditions.',
      'You acknowledge these risks and agree that CryPrice is not liable for losses arising from blockchain or DeFi activity, whether or not you were using the Service at the time.',
    ],
  },
  {
    id: 'availability',
    title: 'Availability and Service Changes',
    paragraphs: [
      'We strive to keep the Service available, but we do not guarantee uninterrupted, timely, or error-free operation.',
      'The Service may be modified, suspended, or discontinued in whole or in part at any time, with or without notice, including changes to supported networks, protocols, features, or data sources.',
      'Maintenance, outages, upstream provider failures, and chain reorganizations may affect data freshness and alert delivery.',
    ],
  },
  {
    id: 'disclaimer-of-warranties',
    title: 'Disclaimer of Warranties',
    paragraphs: [
      'To the fullest extent permitted by applicable law, the Service is provided "as is" and "as available" without warranties of any kind, whether express, implied, or statutory.',
      'We disclaim implied warranties of merchantability, fitness for a particular purpose, title, and non-infringement. We do not warrant that data, alerts, or reports will be accurate, complete, current, or suitable for your needs.',
    ],
  },
  {
    id: 'limitation-of-liability',
    title: 'Limitation of Liability',
    paragraphs: [
      'To the fullest extent permitted by applicable law, CryPrice and its operators will not be liable for any indirect, incidental, special, consequential, exemplary, or punitive damages, or for any loss of profits, data, goodwill, or digital assets, arising from or related to your use of the Service.',
      'Our aggregate liability for any claim arising from these Terms or the Service will not exceed the greater of (a) the amount you paid us for the Service in the twelve months preceding the claim, or (b) one hundred U.S. dollars (USD $100), if you have not paid for the Service.',
      'Some jurisdictions do not allow certain limitations; in those cases, our liability is limited to the maximum extent permitted by law.',
    ],
  },
  {
    id: 'intellectual-property',
    title: 'Intellectual Property',
    paragraphs: [
      'The Service, including its software, design, branding, documentation, and content (excluding user-provided wallet addresses and third-party data), is owned by CryPrice or its licensors and protected by applicable intellectual property laws.',
      'You may not copy, modify, distribute, sell, or create derivative works from the Service except as expressly permitted by us or applicable open-source licenses covering specific components.',
    ],
  },
  {
    id: 'privacy-reference',
    title: 'Privacy Reference',
    paragraphs: [
      `Our Privacy Policy at ${ROUTES.privacy} describes how we handle information when you use the Service, including wallet addresses, authentication data, Telegram identifiers, and usage logs.`,
      'By using the Service, you acknowledge that you have read our Privacy Policy.',
    ],
  },
  {
    id: 'contact',
    title: 'Contact Information',
    paragraphs: [
      `For questions about these Terms, email ${CONTACT.legalEmail} (${CONTACT.legalMailto}).`,
      `For security vulnerability reports, email ${CONTACT.securityEmail} or see ${CONTACT.securityTxtUrl}.`,
    ],
  },
  {
    id: 'last-updated',
    title: 'Last Updated',
    paragraphs: [`These Terms of Service were last updated on ${TERMS_META.lastUpdated}.`],
  },
] as const

export const TERMS_SUMMARY =
  'CryPrice is read-only DeFi monitoring software. We do not custody funds, connect wallets, request private keys, or execute transactions. By using CryPrice, you agree to these Terms and accept that DeFi activity carries significant risk.'
