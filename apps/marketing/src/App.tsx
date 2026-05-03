import { useCallback, useState } from 'react'
import {
  ABOUT_CRYPRICE,
  ASSETS,
  AUTHOR,
  LINKS,
  PUBLIC_API_HOST,
  TECH_STACK_CARDS,
  githubRepoLabel,
  urlHostname,
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
            Cryprice
          </a>
          <nav className="nav" aria-label="Primary">
            <a href="#about-project">About project</a>
            <a href="#about-author">About author</a>
            <a href={LINKS.githubProfile} target="_blank" rel="noreferrer">
              GitHub
            </a>
            <a className="btn btn--primary btn--sm" href={LINKS.app}>
              Open App
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
          <a href="#about-project" onClick={closeMobileNav}>
            About project
          </a>
          <a href="#about-author" onClick={closeMobileNav}>
            About author
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
            Open App
          </a>
        </div>
      </header>

      <main id="top">
        <section className="hero section">
          <div className="hero-glow" aria-hidden="true" />
          <p className="eyebrow">Personal project · full-stack</p>
          <h1 className="hero-title">
            Cryprice — crypto price tracking built by an independent developer
          </h1>
          <p className="hero-sub">
            Compare crypto prices from CEX, DEX and aggregators, calculate
            conversions, and explore a real full-stack Flutter + Node.js project.
          </p>
          <div className="hero-cta">
            <a className="btn btn--primary" href={LINKS.app}>
              Open App
            </a>
            <a className="btn btn--ghost" href="#project-links">
              View source code
            </a>
          </div>
        </section>

        <section className="section" id="about-project">
          <h2 className="section-title">About Cryprice</h2>
          <p className="section-lead">
            Cryprice is a small, honest tool for seeing prices and doing math —
            not a trading venue and not a protocol.
          </p>
          <ul className="about-list">
            {ABOUT_CRYPRICE.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </section>

        <section className="section section--card" id="about-author">
          <h2 className="section-title">About the author</h2>
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
        </section>

        <section className="section" id="project-links">
          <h2 className="section-title">Project links</h2>
          <p className="section-lead">
            Open the app (including in-app Telegram) or browse the repositories.
          </p>
          <div className="link-cards">
            <a className="link-card" href={LINKS.app}>
              <span className="link-card-title">Open App</span>
              <span className="link-card-url">
                {urlHostname(LINKS.app, 'app.cryprice.dev')}
              </span>
            </a>
            <a
              className="link-card"
              href={LINKS.monoRepo}
              target="_blank"
              rel="noreferrer"
            >
              <span className="link-card-title">Cryprice monorepo</span>
              <span className="link-card-url">
                {githubRepoLabel(LINKS.monoRepo, 'adrassad/cryprice')}
              </span>
            </a>
            <a
              className="link-card"
              href={LINKS.webAppPath}
              target="_blank"
              rel="noreferrer"
            >
              <span className="link-card-title">Web app</span>
              <span className="link-card-url">apps/web</span>
            </a>
            <a
              className="link-card"
              href={LINKS.backendPath}
              target="_blank"
              rel="noreferrer"
            >
              <span className="link-card-title">Public backend</span>
              <span className="link-card-url">backend-public</span>
            </a>
          </div>
        </section>

        <section className="section">
          <h2 className="section-title">Tech stack</h2>
          <div className="tech-grid">
            {TECH_STACK_CARDS.map((card) => (
              <article key={card.title} className="tech-card">
                <h3>{card.title}</h3>
                <p>{card.detail}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="section disclaimer" aria-labelledby="disclaimer-heading">
          <h2 id="disclaimer-heading" className="visually-hidden">
            Disclaimer
          </h2>
          <p>
            Cryprice is an informational tool. It does not execute trades and
            should not be considered financial advice.
          </p>
        </section>
      </main>

      <footer className="footer">
        <div className="footer-inner">
          <span className="footer-brand">Cryprice</span>
          <nav className="footer-nav" aria-label="Footer">
            <a href={LINKS.app}>Open App</a>
            <a href={LINKS.monoRepo} target="_blank" rel="noreferrer">
              Monorepo
            </a>
            <a href={LINKS.webAppPath} target="_blank" rel="noreferrer">
              Web app
            </a>
            <a href={LINKS.backendPath} target="_blank" rel="noreferrer">
              Backend
            </a>
            <a href={LINKS.githubProfile} target="_blank" rel="noreferrer">
              GitHub
            </a>
          </nav>
          <p className="footer-note">
            App:{' '}
            <span className="mono">
              {urlHostname(LINKS.app, 'app.cryprice.dev')}
            </span>{' '}
            · API: <span className="mono">{PUBLIC_API_HOST}</span>
          </p>
        </div>
      </footer>
    </div>
  )
}
