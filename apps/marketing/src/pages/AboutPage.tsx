import InfoDocument from '../components/InfoDocument'
import {
  ABOUT_META,
  ABOUT_SECTIONS,
  ABOUT_SUMMARY,
} from '../content/aboutContent'

export default function AboutPage() {
  return (
    <InfoDocument
      meta={ABOUT_META}
      eyebrow="Project"
      documentTitle="About CryPrice"
      summary={ABOUT_SUMMARY}
      sections={ABOUT_SECTIONS}
    />
  )
}
