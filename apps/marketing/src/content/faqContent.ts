import { ROUTES } from '../siteContent'

export const FAQ_META = {
  title: 'FAQ — CryPrice',
  description:
    'Answers about CryPrice read-only DeFi risk monitoring, public address tracking, Aave Health Factor context, and optional notifications.',
  path: ROUTES.faq,
  lastUpdated: 'July 14, 2026',
} as const

export const FAQ_INTRO =
  'CryPrice is read-only DeFi risk intelligence. It monitors public on-chain data and risk signals — it does not connect wallets, request seed phrases, store private keys, sign transactions, or custody funds.'

export const FAQ_ITEMS = [
  {
    id: 'execute-transactions',
    question: 'Does CryPrice execute blockchain transactions?',
    answer:
      'No. CryPrice does not execute blockchain transactions, sign messages, or submit on-chain actions on your behalf. It is a read-only monitoring service.',
  },
  {
    id: 'wallet-connection',
    question: 'Does CryPrice connect to my wallet?',
    answer:
      'No. CryPrice does not connect to wallets and cannot sign transactions. You add public addresses for read-only monitoring only.',
  },
  {
    id: 'wallet-connection-required',
    question: 'Does CryPrice require wallet connection?',
    answer:
      'No. Wallet connection is not required or supported. Monitoring uses public addresses you add manually after CryPrice account access is set up.',
  },
  {
    id: 'seed-phrases',
    question: 'Does CryPrice need my seed phrase?',
    answer:
      'No. CryPrice never asks for seed phrases or recovery phrases — not in the product, by email, Telegram, or any support channel.',
  },
  {
    id: 'private-keys',
    question: 'Does CryPrice ask for private keys?',
    answer:
      'No. CryPrice never asks for private keys, keystore files, or wallet signing credentials.',
  },
  {
    id: 'move-funds',
    question: 'Can CryPrice move my funds?',
    answer:
      'No. CryPrice is read-only. It does not custody funds, execute transactions, or act on your behalf on-chain.',
  },
  {
    id: 'user-data',
    question: 'What data do users add?',
    answer:
      'Users add public addresses they want to monitor. CryPrice retrieves and displays associated public blockchain and protocol data for those addresses.',
  },
  {
    id: 'google-oauth',
    question: 'Why does CryPrice use Google OAuth?',
    answer:
      'Google OAuth is used for CryPrice account access only. It is not wallet access. CryPrice does not receive your Google password.',
  },
  {
    id: 'telegram',
    question: 'Why does CryPrice use Telegram?',
    answer:
      'Telegram is used only for optional notifications you configure — for example, Health Factor or price threshold updates. Linking Telegram is optional and performed after account access is set up.',
  },
  {
    id: 'financial-advice',
    question: 'Is CryPrice financial advice?',
    answer:
      'No. CryPrice provides monitoring and risk visibility only. It does not provide investment, trading, tax, legal, or financial advice.',
  },
  {
    id: 'blockchain-data-collection',
    question: 'How is blockchain data collected?',
    answer:
      'CryPrice reads publicly available on-chain state and protocol data (for example Aave V3 positions) through blockchain RPC providers and backend protocol adapters. Data is aggregated for public addresses you choose to monitor and may be cached or stored to power dashboards, alerts, and reports.',
  },
  {
    id: 'personal-information-stored',
    question: 'What personal information is stored?',
    answer:
      'CryPrice may store account-access data from Google OAuth (such as email and name), public addresses you add for monitoring, optional Telegram identifiers for notifications you configure, and operational logs needed to run the service. See the Privacy Policy for details. CryPrice never stores seed phrases, private keys, or wallet signing credentials.',
  },
  {
    id: 'liquidations',
    question: 'Can CryPrice prevent liquidations?',
    answer:
      'No. CryPrice cannot guarantee liquidation prevention. Data and alerts may be delayed or incomplete. Do not rely on CryPrice as your only risk warning system.',
  },
] as const
