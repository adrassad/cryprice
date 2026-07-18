import { Route, Routes } from 'react-router-dom'
import SiteLayout from './components/SiteLayout'
import AboutPage from './pages/AboutPage'
import ChangelogPage from './pages/ChangelogPage'
import ContactPage from './pages/ContactPage'
import CookiesPage from './pages/CookiesPage'
import DocsPage from './pages/DocsPage'
import FaqPage from './pages/FaqPage'
import LandingPage from './pages/LandingPage'
import PrivacyPage from './pages/PrivacyPage'
import TermsPage from './pages/TermsPage'
import SecurityPage from './pages/SecurityPage'
import StatusPage from './pages/StatusPage'
import SupportedProtocolsPage from './pages/SupportedProtocolsPage'
import TrustPage from './pages/TrustPage'
import TransparencyPage from './pages/TransparencyPage'
import './App.css'

export default function App() {
  return (
    <Routes>
      <Route element={<SiteLayout />}>
        <Route path="/" element={<LandingPage />} />
        <Route path="/about" element={<AboutPage />} />
        <Route path="/privacy" element={<PrivacyPage />} />
        <Route path="/terms" element={<TermsPage />} />
        <Route path="/security" element={<SecurityPage />} />
        <Route path="/trust" element={<TrustPage />} />
        <Route path="/transparency" element={<TransparencyPage />} />
        <Route path="/faq" element={<FaqPage />} />
        <Route path="/contact" element={<ContactPage />} />
        <Route path="/cookies" element={<CookiesPage />} />
        <Route path="/docs" element={<DocsPage />} />
        <Route path="/supported-protocols" element={<SupportedProtocolsPage />} />
        <Route path="/changelog" element={<ChangelogPage />} />
        <Route path="/status" element={<StatusPage />} />
      </Route>
    </Routes>
  )
}
