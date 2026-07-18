import LegalDocument from '../components/LegalDocument'
import { TRUST_META, TRUST_SECTIONS, TRUST_SUMMARY } from '../content/trustContent'

export default function TrustPage() {
  return (
    <LegalDocument
      meta={TRUST_META}
      eyebrow="Trust & Security"
      documentTitle="Trust"
      summary={TRUST_SUMMARY}
      sections={TRUST_SECTIONS}
    />
  )
}
