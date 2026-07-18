import { Link } from 'react-router-dom'
import PageMeta from '../components/PageMeta'
import { DOCS_META, DOCS_SUMMARY } from '../content/docsContent'
import { LINKS, ROUTES } from '../siteContent'

const DOC_LINKS = [
  { label: 'Security model', path: ROUTES.security },
  { label: 'FAQ', path: ROUTES.faq },
  { label: 'Supported protocols', path: ROUTES.supportedProtocols },
  { label: 'About', path: ROUTES.about },
  { label: 'Privacy policy', path: ROUTES.privacy },
  { label: 'Terms of service', path: ROUTES.terms },
  { label: 'Cookie policy', path: ROUTES.cookies },
  { label: 'Changelog', path: ROUTES.changelog },
  { label: 'Status', path: ROUTES.status },
] as const

const REPO_LINKS = [
  { label: 'Public monorepository', href: LINKS.monoRepo },
  { label: 'Web app source', href: LINKS.webAppPath },
  { label: 'Backend source', href: LINKS.backendPath },
] as const

export default function DocsPage() {
  return (
    <>
      <PageMeta title={DOCS_META.title} description={DOCS_META.description} path={DOCS_META.path} />
      <main className="legal-main" id="top">
        <article className="section section--card legal-doc">
          <p className="eyebrow">Documentation</p>
          <h1 className="section-title">Documentation</h1>
          <p className="section-lead legal-updated">Last updated: {DOCS_META.lastUpdated}</p>
          <p className="legal-summary">{DOCS_SUMMARY}</p>

          <section className="legal-section" id="product-docs" aria-labelledby="product-docs-heading">
            <h2 className="legal-section-title" id="product-docs-heading">
              Product documentation
            </h2>
            <ul className="about-list">
              {DOC_LINKS.map((item) => (
                <li key={item.path}>
                  <Link to={item.path}>{item.label}</Link>
                </li>
              ))}
            </ul>
          </section>

          <section className="legal-section" id="application" aria-labelledby="application-heading">
            <h2 className="legal-section-title" id="application-heading">
              Application
            </h2>
            <p>
              The authenticated product dashboard is available at{' '}
              <a href={LINKS.app} target="_blank" rel="noopener noreferrer">
                app.cryprice.dev
              </a>
              . Account access is separate from wallet access.
            </p>
          </section>

          <section className="legal-section" id="api" aria-labelledby="api-heading">
            <h2 className="legal-section-title" id="api-heading">
              API and engineering references
            </h2>
            <p>
              The public API host is{' '}
              <a href="https://api.cryprice.dev/" target="_blank" rel="noopener noreferrer">
                api.cryprice.dev
              </a>
              . Portfolio and risk endpoints require authenticated sessions for user-specific data.
            </p>
            <ul className="about-list">
              {REPO_LINKS.map((item) => (
                <li key={item.href}>
                  <a href={item.href} target="_blank" rel="noreferrer">
                    {item.label}
                  </a>
                </li>
              ))}
            </ul>
          </section>
        </article>
      </main>
    </>
  )
}
