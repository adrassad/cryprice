import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ isSsrBuild }) => ({
  plugins: [react()],
  build: isSsrBuild
    ? {
        ssr: true,
        outDir: 'dist-ssr',
        emptyOutDir: true,
        rollupOptions: {
          input: 'src/prerender.tsx',
        },
      }
    : {
        outDir: 'dist',
        emptyOutDir: true,
      },
  ssr: {
    noExternal: ['react-helmet-async'],
  },
}))
