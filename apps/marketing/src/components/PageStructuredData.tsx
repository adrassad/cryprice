import { Helmet } from 'react-helmet-async'

type PageStructuredDataProps = {
  data: Record<string, unknown>
}

export default function PageStructuredData({ data }: PageStructuredDataProps) {
  const structuredData = {
    '@context': 'https://schema.org',
    ...data,
  }

  return (
    <Helmet>
      <script type="application/ld+json">{JSON.stringify(structuredData)}</script>
    </Helmet>
  )
}
