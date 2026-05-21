import { useCallback, useState } from 'react'
import {
  ARCHITECTURE_SNAPSHOT,
  ASSETS,
  AUTHOR,
  DISCLAIMER,
  FEATURES,
  HERO,
  HOW_IT_WORKS,
  INFRASTRUCTURE_OVERVIEW,
  LINKS,
  MILESTONES,
  PROBLEM,
  PROJECT_LINK_CARDS,
  PUBLIC_WORK,
  ROADMAP,
  SOLUTION,
  TECHNICAL_CONTRIBUTIONS,
  TRUST_STRIP,
} from './siteContent'
import './App.css'

function closeMobileNav() {
  document.body.classList.remove('nav-open')
}

function XIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      aria-hidden="true"
      focusable="false"
    >
      <path
        fill="currentColor"
        d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
      />
    </svg>
  )
}

function LinkedInIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      aria-hidden="true"
      focusable="false"
    >
      <path
        fill="currentColor"
        d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"
      />
    </svg>
  )
}

function AuthorPhoto() {
  const [failed, setFailed] = useState(false)
  const onError = useCallback(() => setFailed(true), [])

  return (
    <div className="author-photo-wrap" aria-hidden={failed}>
      {!failed ? (
        <img
          className="author-photo"
          src={AUTHOR.photoSrc}
          alt={AUTHOR.photoAlt}
          width={160}
          height={160}
          loading="lazy"
          decoding="async"
          onError={onError}
        />
      ) : null}
      <div
        className={`author-photo-placeholder${failed ? ' author-photo-placeholder--visible' : ''}`}
        aria-hidden="true"
      >
        <span className="author-photo-initials" aria-hidden="true">
          {AUTHOR.name
            .split(/\s+/)
            .map((w) => w[0])
            .join('')
            .slice(0, 2)
            .toUpperCase()}
        </span>
        <span className="author-photo-hint">Add photo: src/assets/author.jpg</span>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <div className="page">
      <header className="header">
        <div className="header-inner">
          <a className="logo" href="#top">
            <span className="logo-mark" aria-hidden="true">
              <img
                className="logo-mark-img"
                src={ASSETS.logoMark}
                alt=""
                width={28}
                height={28}
                decoding="async"
              />
            </span>
            CryPrice
          </a>
          <nav className="nav" aria-label="Primary">
            <a href="#features">Features</a>
            <a href="#how-it-works">How it works</a>
            <a href="#roadmap">Roadmap</a>
            <a href="#founder">Founder</a>
            <a href={LINKS.githubProfile} target="_blank" rel="noreferrer">
              GitHub
            </a>
            <a className="btn btn--primary btn--sm" href={LINKS.app}>
              {HERO.primaryCta}
            </a>
          </nav>
          <button
            type="button"
            className="nav-toggle"
            aria-label="Open menu"
            onClick={() => document.body.classList.toggle('nav-open')}
          >
            <span />
            <span />
          </button>
        </div>
        <div className="mobile-nav" id="mobile-nav">
          <a href="#features" onClick={closeMobileNav}>
            Features
          </a>
          <a href="#how-it-works" onClick={closeMobileNav}>
            How it works
          </a>
          <a href="#roadmap" onClick={closeMobileNav}>
            Roadmap
          </a>
          <a href="#founder" onClick={closeMobileNav}>
            Founder
          </a>
          <a
            href={LINKS.githubProfile}
            target="_blank"
            rel="noreferrer"
            onClick={closeMobileNav}
          >
            GitHub
          </a>
          <a className="btn btn--primary" href={LINKS.app} onClick={closeMobileNav}>
            {HERO.primaryCta}
          </a>
        </div>
      </header>

      <main id="top">
        <section className="hero section">
          <div className="hero-glow" aria-hidden="true" />
          <p className="eyebrow">{HERO.eyebrow}</p>
          <h1 className="hero-title">{HERO.title}</h1>
          <p className="hero-sub">{HERO.subheadline}</p>
          <div className="hero-cta">
            <a className="btn btn--primary" href={LINKS.app}>
              {HERO.primaryCta}
            </a>
            <a className="btn btn--ghost" href="#problem">
              {HERO.secondaryCta}
            </a>
          </div>
        </section>

        <section className="trust-strip" aria-label="Platform safety highlights">
          <div className="trust-strip-inner">
            <ul className="trust-strip-list">
              {TRUST_STRIP.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </div>
        </section>

        <section className="section" id="problem">
          <h2 className="section-title">{PROBLEM.title}</h2>
          <p className="section-lead">{PROBLEM.lead}</p>
          <ul className="about-list">
            {PROBLEM.points.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </section>

        <section className="section" id="solution">
          <h2 className="section-title">{SOLUTION.title}</h2>
          <p className="section-lead">{SOLUTION.lead}</p>
          <ul className="about-list">
            {SOLUTION.points.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </section>

        <section className="section" id="features">
          <h2 className="section-title">{FEATURES.title}</h2>
          <p className="section-lead">{FEATURES.lead}</p>
          <div className="tech-grid">
            {FEATURES.cards.map((card) => (
              <article key={card.title} className="tech-card">
                <h3>{card.title}</h3>
                <p>{card.detail}</p>
              </article>
            ))}
          </div>
          <p className="section-note">{FEATURES.scopeNote}</p>
        </section>

        <section className="section" id="how-it-works">
          <h2 className="section-title">{HOW_IT_WORKS.title}</h2>
          <p className="section-lead">{HOW_IT_WORKS.lead}</p>
          <ol className="steps-list">
            {HOW_IT_WORKS.steps.map((step, index) => (
              <li key={step.title} className="steps-item">
                <span className="steps-number" aria-hidden="true">
                  {index + 1}
                </span>
                <div className="steps-copy">
                  <h3>{step.title}</h3>
                  <p>{step.detail}</p>
                </div>
              </li>
            ))}
          </ol>
        </section>

        <section className="section" id="infrastructure">
          <h2 className="section-title">Infrastructure overview</h2>
          <p className="section-lead">{INFRASTRUCTURE_OVERVIEW.lead}</p>
          <div
            className="arch-flow"
            aria-label="CryPrice architecture flow from clients through APIs and monitoring to data stores and alerts"
          >
            {INFRASTRUCTURE_OVERVIEW.flow.map((step, index) => (
              <div key={step} className="arch-flow-item">
                <span className="arch-flow-step">{step}</span>
                {index < INFRASTRUCTURE_OVERVIEW.flow.length - 1 ? (
                  <span className="arch-flow-arrow" aria-hidden="true">
                    →
                  </span>
                ) : null}
              </div>
            ))}
          </div>
          <div className="tech-grid">
            {INFRASTRUCTURE_OVERVIEW.cards.map((card) => (
              <article key={card.title} className="tech-card">
                <h3>{card.title}</h3>
                <p>{card.detail}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="section" id="roadmap">
          <h2 className="section-title">{ROADMAP.title}</h2>
          <p className="section-lead">{ROADMAP.lead}</p>
          <ul className="research-list">
            {ROADMAP.items.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </section>

        <section className="section section--card" id="founder">
          <h2 className="section-title">{AUTHOR.sectionTitle}</h2>
          <p className="section-lead">{AUTHOR.lead}</p>
          <p className="section-note section-note--lead-follow">{AUTHOR.supportingCopy}</p>
          <div className="author-grid">
            <AuthorPhoto />
            <div className="author-copy">
              <div className="author-intro">
                <h3 className="author-name">
                  {AUTHOR.name}
                  <span className="author-role">{AUTHOR.title}</span>
                </h3>
                <div className="author-socials">
                  <a
                    className="author-social-link"
                    href={LINKS.githubProfile}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={`View ${AUTHOR.name} on GitHub`}
                  >
                    <span>GitHub</span>
                  </a>
                  <a
                    className="author-social-link"
                    href={LINKS.xProfile}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={`View ${AUTHOR.name} on X`}
                  >
                    <XIcon className="author-social-icon" />
                    <span>{AUTHOR.xHandle}</span>
                  </a>
                  <a
                    className="author-social-link"
                    href={LINKS.linkedIn}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={`View ${AUTHOR.name} on LinkedIn`}
                  >
                    <LinkedInIcon className="author-social-icon" />
                    <span>{AUTHOR.linkedInLabel}</span>
                  </a>
                </div>
              </div>
              <div className="author-bio">
                {AUTHOR.bioParagraphs.map((paragraph, index) => (
                  <p key={index}>{paragraph}</p>
                ))}
              </div>
              <p className="author-tech-label">Built with</p>
              <ul className="tag-list">
                {AUTHOR.techTags.map((t) => (
                  <li key={t}>{t}</li>
                ))}
              </ul>
            </div>
          </div>

          <div className="credibility-block" id="technical-contributions">
            <h3 className="credibility-title">{TECHNICAL_CONTRIBUTIONS.title}</h3>
            <p className="section-lead">{TECHNICAL_CONTRIBUTIONS.lead}</p>
            <div className="tech-grid">
              {TECHNICAL_CONTRIBUTIONS.items.map((item) => (
                <article key={item.title} className="tech-card">
                  <h3>{item.title}</h3>
                  <p>{item.detail}</p>
                </article>
              ))}
            </div>
          </div>

          <div className="credibility-block" id="milestones">
            <h3 className="credibility-title">{MILESTONES.title}</h3>
            <p className="section-lead">{MILESTONES.lead}</p>
            <ol className="steps-list">
              {MILESTONES.items.map((item, index) => (
                <li
                  key={item.title}
                  className={`steps-item${'planned' in item && item.planned ? ' steps-item--planned' : ''}`}
                >
                  <span className="steps-number" aria-hidden="true">
                    {index + 1}
                  </span>
                  <div className="steps-copy">
                    <h3>{item.title}</h3>
                    <p>{item.detail}</p>
                  </div>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section className="section" id="public-work">
          <h2 className="section-title">{PUBLIC_WORK.title}</h2>
          <p className="section-lead">{PUBLIC_WORK.lead}</p>
          <div className="public-work-links">
            {PUBLIC_WORK.links.map((link) => (
              <a
                key={link.label}
                className="author-social-link"
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
              >
                {link.label}
              </a>
            ))}
          </div>
        </section>

        <section className="section" id="architecture-snapshot">
          <h2 className="section-title">{ARCHITECTURE_SNAPSHOT.title}</h2>
          <p className="section-lead">{ARCHITECTURE_SNAPSHOT.lead}</p>
          <div
            className="arch-flow"
            aria-label="CryPrice read-only monitoring data flow"
          >
            {ARCHITECTURE_SNAPSHOT.flow.map((step, index) => (
              <div key={step} className="arch-flow-item">
                <span className="arch-flow-step">{step}</span>
                {index < ARCHITECTURE_SNAPSHOT.flow.length - 1 ? (
                  <span className="arch-flow-arrow" aria-hidden="true">
                    →
                  </span>
                ) : null}
              </div>
            ))}
          </div>
        </section>

        <section className="section" id="project-links">
          <h2 className="section-title">Project links</h2>
          <p className="section-lead">
            Open the live app or review public engineering repositories and source trees.
          </p>
          <div className="link-cards">
            {PROJECT_LINK_CARDS.map((card) => (
              <a
                key={card.title}
                className="link-card"
                href={card.href}
                {...(card.external
                  ? { target: '_blank', rel: 'noreferrer' }
                  : {})}
              >
                <span className="link-card-title">{card.title}</span>
                <span className="link-card-url">{card.url}</span>
              </a>
            ))}
          </div>
        </section>

        <section className="section disclaimer" aria-labelledby="disclaimer-heading">
          <h2 id="disclaimer-heading" className="visually-hidden">
            Disclaimer
          </h2>
          <p>{DISCLAIMER}</p>
        </section>
      </main>

      <footer className="footer">
        <div className="footer-inner">
          <span className="footer-brand">CryPrice</span>
          <nav className="footer-nav" aria-label="Footer">
            <a href={LINKS.app}>Open App</a>
            <a href={LINKS.monoRepo} target="_blank" rel="noreferrer">
              Public Repository
            </a>
            <a href={LINKS.webAppPath} target="_blank" rel="noreferrer">
              Web App Source
            </a>
            <a href={LINKS.backendPath} target="_blank" rel="noreferrer">
              Backend Source
            </a>
            <a href={LINKS.githubProfile} target="_blank" rel="noreferrer">
              GitHub Profile
            </a>
          </nav>
          <p className="footer-note">
            App: <span className="mono">app.cryprice.dev</span> · API:{' '}
            <span className="mono">api.cryprice.dev</span>
          </p>
        </div>
      </footer>
    </div>
  )
}
