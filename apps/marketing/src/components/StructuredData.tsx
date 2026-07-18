import { Helmet } from 'react-helmet-async'
import { buildSiteStructuredDataGraph } from '../seo/structuredData'

export default function StructuredData() {
  const structuredData = {
    '@context': 'https://schema.org',
    '@graph': buildSiteStructuredDataGraph(),
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(structuredData)}</script>
    </Helmet>
  )
}
