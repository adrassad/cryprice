import { Link } from 'react-router-dom'
import PageStructuredData from '../components/PageStructuredData'
import PageMeta from '../components/PageMeta'
import { FAQ_INTRO, FAQ_ITEMS, FAQ_META } from '../content/faqContent'
import { buildFaqPageStructuredData } from '../seo/structuredData'
import { ROUTES } from '../siteContent'

export default function FaqPage() {
  return (
    <>
      <PageMeta title={FAQ_META.title} description={FAQ_META.description} path={FAQ_META.path} />
      <PageStructuredData data={buildFaqPageStructuredData()} />
      <main className="legal-main" id="top">
        <article className="section section--card legal-doc">
          <p className="eyebrow">Help</p>
          <h1 className="section-title">FAQ</h1>
          <p className="section-lead legal-updated">Last updated: {FAQ_META.lastUpdated}</p>
          <p className="legal-summary">{FAQ_INTRO}</p>

          {FAQ_ITEMS.map((item) => (
            <section key={item.id} className="faq-item" id={item.id} aria-labelledby={`${item.id}-heading`}>
              <h2 className="faq-question" id={`${item.id}-heading`}>
                {item.question}
              </h2>
              <p>{item.answer}</p>
            </section>
          ))}

          <p className="faq-related">
            For the full security model, see <Link to={ROUTES.security}>Security</Link>,{' '}
            <Link to={ROUTES.trust}>Trust</Link>, and{' '}
            <Link to={ROUTES.transparency}>Transparency</Link>. For supported scope, see{' '}
            <Link to={ROUTES.supportedProtocols}>Supported Protocols</Link>.
          </p>
        </article>
      </main>
    </>
  )
}
