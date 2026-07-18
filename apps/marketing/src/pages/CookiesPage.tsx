import InfoDocument from '../components/InfoDocument'
import {
  COOKIES_META,
  COOKIES_SECTIONS,
  COOKIES_SUMMARY,
} from '../content/cookiesContent'

export default function CookiesPage() {
  return (
    <InfoDocument
      meta={COOKIES_META}
      eyebrow="Legal"
      documentTitle="Cookie Policy"
      summary={COOKIES_SUMMARY}
      sections={COOKIES_SECTIONS}
    />
  )
}
