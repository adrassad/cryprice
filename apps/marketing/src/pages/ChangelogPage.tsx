import InfoDocument from '../components/InfoDocument'
import {
  CHANGELOG_META,
  CHANGELOG_SECTIONS,
  CHANGELOG_SUMMARY,
} from '../content/changelogContent'

export default function ChangelogPage() {
  return (
    <InfoDocument
      meta={CHANGELOG_META}
      eyebrow="Product"
      documentTitle="Changelog"
      summary={CHANGELOG_SUMMARY}
      sections={CHANGELOG_SECTIONS}
    />
  )
}
