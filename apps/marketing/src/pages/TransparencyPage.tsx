import LegalDocument from '../components/LegalDocument'
import {
  TRANSPARENCY_META,
  TRANSPARENCY_SECTIONS,
  TRANSPARENCY_SUMMARY,
} from '../content/transparencyContent'

export default function TransparencyPage() {
  return (
    <LegalDocument
      meta={TRANSPARENCY_META}
      eyebrow="Transparency"
      documentTitle="Transparency"
      summary={TRANSPARENCY_SUMMARY}
      sections={TRANSPARENCY_SECTIONS}
    />
  )
}
