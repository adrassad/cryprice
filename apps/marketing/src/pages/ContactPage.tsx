import { Link } from 'react-router-dom'
import ContactForm from '../components/ContactForm'
import PageMeta from '../components/PageMeta'
import {
  CONTACT_DETAILS,
  CONTACT_INTRO,
  CONTACT_META,
  CONTACT_RELATED_LINKS,
} from '../content/contactContent'

export default function ContactPage() {
  return (
    <>
      <PageMeta
        title={CONTACT_META.title}
        description={CONTACT_META.description}
        path={CONTACT_META.path}
      />
      <main className="legal-main" id="top">
        <article className="section section--card legal-doc">
          <p className="eyebrow">Project</p>
          <h1 className="section-title">Contact</h1>
          <p className="section-lead legal-updated">Last updated: {CONTACT_META.lastUpdated}</p>
          <p className="legal-summary">{CONTACT_INTRO}</p>

          <ContactForm />

          <h2 className="legal-section-title">Contact channels</h2>
          <dl className="contact-list">
            {CONTACT_DETAILS.map((item) => (
              <div key={item.label} className="contact-row">
                <dt>{item.label}</dt>
                <dd>
                  {'href' in item && item.href ? (
                    <a
                      href={item.href}
                      {...('external' in item && item.external
                        ? { target: '_blank', rel: 'noreferrer' }
                        : {})}
                    >
                      {item.value}
                    </a>
                  ) : (
                    item.value
                  )}
                </dd>
              </div>
            ))}
          </dl>

          <nav className="contact-related" aria-label="Related pages">
            {CONTACT_RELATED_LINKS.map((link, index) => (
              <span key={link.path}>
                {index > 0 ? ' · ' : null}
                <Link to={link.path}>{link.label}</Link>
              </span>
            ))}
          </nav>
        </article>
      </main>
    </>
  )
}
