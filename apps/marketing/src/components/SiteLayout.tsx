import { Outlet } from 'react-router-dom'
import ScrollToTop from './ScrollToTop'
import SiteFooter from './SiteFooter'
import SiteHeader from './SiteHeader'
import StructuredData from './StructuredData'

export default function SiteLayout() {
  return (
    <div className="page">
      <StructuredData />
      <ScrollToTop />
      <SiteHeader />
      <Outlet />
      <SiteFooter />
    </div>
  )
}
