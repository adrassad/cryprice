/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Full URL of the web app (e.g. https://app.example.com) */
  readonly VITE_PUBLIC_APP_URL?: string
  /** API hostname without scheme (e.g. api.example.com) — shown in footer copy only */
  readonly VITE_PUBLIC_API_HOST?: string
  readonly VITE_PUBLIC_MONOREPO_URL?: string
  readonly VITE_PUBLIC_WEB_APP_PATH_URL?: string
  readonly VITE_PUBLIC_BACKEND_PATH_URL?: string
  readonly VITE_PUBLIC_GITHUB_PROFILE_URL?: string
  readonly VITE_PUBLIC_LINKEDIN_URL?: string
  readonly VITE_PUBLIC_X_PROFILE_URL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
