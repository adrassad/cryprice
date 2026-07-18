import LegalDocument from '../components/LegalDocument'
import {
  PRIVACY_META,
  PRIVACY_SECTIONS,
} from '../content/legal/privacyContent'

const PRIVACY_SUMMARY =
  'CryPrice is a read-only DeFi risk intelligence service. We process public wallet addresses (public blockchain addresses you choose to monitor) for read-only monitoring only — not wallet connections. We do not connect wallets, custody funds, request seed phrases or private keys, request wallet signatures, or execute transactions. Google OAuth is for CryPrice account access only; Telegram identifiers are for optional notifications you configure. This policy describes what information we may process when you use CryPrice.'

export default function PrivacyPage() {
  return (
    <LegalDocument
      meta={PRIVACY_META}
      documentTitle="Privacy Policy"
      summary={PRIVACY_SUMMARY}
      sections={PRIVACY_SECTIONS}
    />
  )
}
