import { ROUTES } from '../siteContent'
import type { InfoSection } from '../components/InfoDocument'

export const SUPPORTED_PROTOCOLS_META = {
  title: 'Supported Protocols — CryPrice',
  description:
    'Networks and DeFi protocols supported by CryPrice read-only monitoring, including Aave V3 on Ethereum, Arbitrum, Avalanche, and Base.',
  path: ROUTES.supportedProtocols,
  lastUpdated: 'June 29, 2026',
} as const

export const SUPPORTED_PROTOCOLS_SUMMARY =
  'CryPrice is built as a protocol-adapter monitoring stack. Aave V3 is the primary implemented adapter today. Additional protocols appear on the public roadmap and may be added over time.'

export const SUPPORTED_PROTOCOLS_SECTIONS: readonly InfoSection[] = [
  {
    id: 'networks',
    title: 'Supported networks',
    paragraphs: ['CryPrice currently monitors read-only portfolio and DeFi context across:'],
    list: ['Ethereum', 'Arbitrum', 'Avalanche', 'Base'],
  },
  {
    id: 'protocols-live',
    title: 'Implemented protocol adapters',
    paragraphs: ['Live monitoring scope today focuses on:'],
    list: [
      'Aave V3 — supplied collateral, borrowed debt, Health Factor context, and protocol exposure views',
    ],
  },
  {
    id: 'protocols-planned',
    title: 'Planned protocol expansion',
    paragraphs: [
      'The backend adapter architecture is designed for additional DeFi integrations. Public roadmap examples include Fluid, Lido, BENQI, and Uniswap V3/V4. Planned items are not live until announced in the changelog.',
    ],
  },
  {
    id: 'read-only-scope',
    title: 'Read-only scope',
    paragraphs: [
      'Supported protocol coverage means read-only observation of public on-chain and protocol data for addresses you choose to track. CryPrice does not execute transactions or act as a wallet.',
      `For product scope and security boundaries, see ${ROUTES.security}.`,
    ],
  },
] as const
