import LegalDocument from '../components/LegalDocument'
import {
  SECURITY_META,
  SECURITY_SECTIONS,
  SECURITY_SUMMARY,
} from '../content/legal/securityContent'

export default function SecurityPage() {
  return (
    <LegalDocument
      meta={SECURITY_META}
      eyebrow="Trust & Security"
      documentTitle="Security"
      summary={SECURITY_SUMMARY}
      sections={SECURITY_SECTIONS}
    />
  )
}
