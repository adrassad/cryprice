import { Link } from 'react-router-dom'
import PageMeta from '../components/PageMeta'
import { STATUS_META, STATUS_SUMMARY } from '../content/statusContent'
import { LINKS, ROUTES } from '../siteContent'

export default function StatusPage() {
  return (
    <>
      <PageMeta title={STATUS_META.title} description={STATUS_META.description} path={STATUS_META.path} />
      <main className="legal-main" id="top">
        <article className="section section--card legal-doc">
          <p className="eyebrow">Operations</p>
          <h1 className="section-title">Service Status</h1>
          <p className="section-lead legal-updated">Last updated: {STATUS_META.lastUpdated}</p>
          <p className="legal-summary">{STATUS_SUMMARY}</p>

          <section className="legal-section" id="current-status" aria-labelledby="current-status-heading">
            <h2 className="legal-section-title" id="current-status-heading">
              Current status
            </h2>
            <p>As of the last update on this page, the public CryPrice surfaces are expected to be available:</p>
            <ul className="about-list">
              <li>
                <a href="https://cryprice.dev/">cryprice.dev</a> — marketing site and documentation
              </li>
              <li>
                <a href={LINKS.app} target="_blank" rel="noopener noreferrer">
                  app.cryprice.dev
                </a>{' '}
                — authenticated web dashboard
              </li>
              <li>
                <a href="https://api.cryprice.dev/" target="_blank" rel="noopener noreferrer">
                  api.cryprice.dev
                </a>{' '}
                — read-only backend API
              </li>
            </ul>
            <p>
              Temporary outages may occur during maintenance, upstream provider issues, or network
              disruptions. Data freshness can vary by chain, protocol, and provider.
            </p>
          </section>

          <section className="legal-section" id="dependencies" aria-labelledby="dependencies-heading">
            <h2 className="legal-section-title" id="dependencies-heading">
              External dependencies
            </h2>
            <p>
              CryPrice depends on blockchain nodes, DeFi protocol data sources, market data providers,
              cloud infrastructure, Google account access, and optional notification channels. Issues
              outside CryPrice infrastructure may affect data accuracy or alert delivery.
            </p>
          </section>

          <section className="legal-section" id="reporting" aria-labelledby="reporting-heading">
            <h2 className="legal-section-title" id="reporting-heading">
              Report an issue
            </h2>
            <p>
              For security vulnerabilities, use the responsible disclosure process documented on the
              security page. For general product inquiries, use the contact page or email listed in the
              footer.
            </p>
            <nav className="contact-related" aria-label="Related pages">
              <Link to={ROUTES.security}>Security</Link> · <Link to={ROUTES.contact}>Contact</Link> ·{' '}
              <a href={LINKS.monoRepo} target="_blank" rel="noreferrer">
                GitHub
              </a>
            </nav>
          </section>
        </article>
      </main>
    </>
  )
}
