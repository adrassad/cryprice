import { Link } from 'react-router-dom'
import { APP_LINK_PROPS, CONTACT, HERO, LINKS, OFFICIAL_DOMAINS, ROUTES } from '../siteContent'

export default function SiteFooter() {
  return (
    <footer className="footer">
      <div className="footer-inner">
        <span className="footer-brand">CryPrice</span>
        <nav className="footer-nav" aria-label="Footer">
          <a href={LINKS.app} {...APP_LINK_PROPS}>
            {HERO.primaryCta}
          </a>
          <Link to={ROUTES.about}>About</Link>
          <Link to={ROUTES.docs}>Docs</Link>
          <Link to={ROUTES.security}>Security</Link>
          <Link to={ROUTES.trust}>Trust</Link>
          <Link to={ROUTES.transparency}>Transparency</Link>
          <Link to={ROUTES.privacy}>Privacy</Link>
          <Link to={ROUTES.terms}>Terms</Link>
          <Link to={ROUTES.cookies}>Cookies</Link>
          <Link to={ROUTES.faq}>FAQ</Link>
          <Link to={ROUTES.status}>Status</Link>
          <a href={LINKS.monoRepo} target="_blank" rel="noreferrer">
            GitHub
          </a>
          <Link to={ROUTES.contact}>Contact</Link>
        </nav>
        <div className="footer-domains" aria-label="Official domains">
          <p className="footer-domains-title">Official Domains</p>
          <ul className="footer-domains-list">
            {OFFICIAL_DOMAINS.map((domain) => (
              <li key={domain.label}>
                <a
                  href={domain.href}
                  {...(domain.label === 'cryprice.dev'
                    ? {}
                    : { target: '_blank', rel: 'noopener noreferrer' })}
                >
                  {domain.label}
                </a>
              </li>
            ))}
          </ul>
        </div>
        <p className="footer-note">
          Read-only DeFi risk intelligence ·{' '}
          <a href={CONTACT.securityMailto} className="footer-contact-link">
            {CONTACT.securityEmail}
          </a>
        </p>
      </div>
    </footer>
  )
}
