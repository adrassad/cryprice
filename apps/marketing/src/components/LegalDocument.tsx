import PageMeta from '../components/PageMeta'
import type { LegalSection } from '../content/legal/types'

type LegalDocumentProps = {
  meta: {
    title: string
    description: string
    path: string
    lastUpdated: string
  }
  eyebrow?: string
  documentTitle: string
  summary: string
  sections: readonly LegalSection[]
}

export default function LegalDocument({
  meta,
  eyebrow = 'Legal',
  documentTitle,
  summary,
  sections,
}: LegalDocumentProps) {
  return (
    <>
      <PageMeta title={meta.title} description={meta.description} path={meta.path} />
      <main className="legal-main" id="top">
        <article className="section section--card legal-doc">
          <p className="eyebrow">{eyebrow}</p>
          <h1 className="section-title">{documentTitle}</h1>
          <p className="section-lead legal-updated">Last updated: {meta.lastUpdated}</p>
          <p className="legal-summary">{summary}</p>

          {sections.map((section) => (
            <section
              key={section.id}
              className="legal-section"
              id={section.id}
              aria-labelledby={`${section.id}-heading`}
            >
              <h2 className="legal-section-title" id={`${section.id}-heading`}>
                {section.title}
              </h2>
              {section.paragraphs.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
              {section.list ? (
                <ul className="about-list">
                  {section.list.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              ) : null}
              {section.paragraphsAfterList?.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
            </section>
          ))}
        </article>
      </main>
    </>
  )
}
