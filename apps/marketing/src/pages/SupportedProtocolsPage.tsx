import InfoDocument from '../components/InfoDocument'
import {
  SUPPORTED_PROTOCOLS_META,
  SUPPORTED_PROTOCOLS_SECTIONS,
  SUPPORTED_PROTOCOLS_SUMMARY,
} from '../content/supportedProtocolsContent'

export default function SupportedProtocolsPage() {
  return (
    <InfoDocument
      meta={SUPPORTED_PROTOCOLS_META}
      eyebrow="Product"
      documentTitle="Supported Protocols"
      summary={SUPPORTED_PROTOCOLS_SUMMARY}
      sections={SUPPORTED_PROTOCOLS_SECTIONS}
    />
  )
}
