import { Link } from 'react-router-dom'
import { ASSETS, APP_LINK_PROPS, HERO, LINKS, ROUTES } from '../siteContent'

function closeMobileNav() {
  document.body.classList.remove('nav-open')
}

export default function SiteHeader() {
  return (
    <header className="header">
      <div className="header-inner">
        <Link className="logo" to="/">
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
        </Link>
        <nav className="nav" aria-label="Primary">
          <Link to={ROUTES.docs}>Docs</Link>
          <Link to={ROUTES.security}>Security</Link>
          <Link to={ROUTES.faq}>FAQ</Link>
          <a href={LINKS.monoRepo} target="_blank" rel="noreferrer">
            GitHub
          </a>
          <a className="btn btn--primary btn--sm" href={LINKS.app} {...APP_LINK_PROPS}>
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
        <Link to={ROUTES.docs} onClick={closeMobileNav}>
          Docs
        </Link>
        <Link to={ROUTES.security} onClick={closeMobileNav}>
          Security
        </Link>
        <Link to={ROUTES.faq} onClick={closeMobileNav}>
          FAQ
        </Link>
        <a
          href={LINKS.monoRepo}
          target="_blank"
          rel="noreferrer"
          onClick={closeMobileNav}
        >
          GitHub
        </a>
        <a
          className="btn btn--primary"
          href={LINKS.app}
          {...APP_LINK_PROPS}
          onClick={closeMobileNav}
        >
          {HERO.primaryCta}
        </a>
      </div>
    </header>
  )
}
