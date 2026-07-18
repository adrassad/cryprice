/**
 * SSR entry for build-time prerendering.
 * React 19 renders Helmet title/meta/link inline in the HTML stream;
 * scripts/prerender.mjs hoists those tags into <head> after renderToString.
 */
import { renderToString } from 'react-dom/server'
import { HelmetProvider } from 'react-helmet-async'
import { StaticRouter } from 'react-router-dom'
import App from './App'

export type PrerenderResult = {
  appHtml: string
}

export function renderRoute(url: string): PrerenderResult {
  const appHtml = renderToString(
    <HelmetProvider>
      <StaticRouter location={url}>
        <App />
      </StaticRouter>
    </HelmetProvider>,
  )

  return { appHtml }
}
