import LegalDocument from '../components/LegalDocument'
import {
  TERMS_META,
  TERMS_SECTIONS,
  TERMS_SUMMARY,
} from '../content/legal/termsContent'

export default function TermsPage() {
  return (
    <LegalDocument
      meta={TERMS_META}
      documentTitle="Terms of Service"
      summary={TERMS_SUMMARY}
      sections={TERMS_SECTIONS}
    />
  )
}
