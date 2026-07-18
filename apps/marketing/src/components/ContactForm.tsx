import { useCallback, useEffect, useId, useRef, useState } from 'react'
import { CONTACT_FORM_TOPICS } from '../content/contactContent'
import { LINKS } from '../siteContent'

const API_CONTACT_URL = `${LINKS.api}/public/contact`
const TURNSTILE_SCRIPT_SRC =
  'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'

type FormState = 'idle' | 'submitting' | 'success' | 'error'

type ContactFormProps = {
  className?: string
}

type TurnstileApi = {
  render: (
    container: HTMLElement,
    options: {
      sitekey: string
      callback: (token: string) => void
      'expired-callback'?: () => void
      'error-callback'?: () => void
      theme?: 'light' | 'dark' | 'auto'
    },
  ) => string
  reset: (widgetId?: string) => void
  remove: (widgetId?: string) => void
}

declare global {
  interface Window {
    turnstile?: TurnstileApi
  }
}

function getTurnstileSiteKey(): string | undefined {
  const key = import.meta.env.VITE_TURNSTILE_SITE_KEY
  if (typeof key !== 'string') {
    return undefined
  }
  const trimmed = key.trim()
  return trimmed.length > 0 ? trimmed : undefined
}

function loadTurnstileScript(): Promise<void> {
  if (window.turnstile) {
    return Promise.resolve()
  }

  const existing = document.querySelector<HTMLScriptElement>(
    `script[src^="${TURNSTILE_SCRIPT_SRC}"]`,
  )
  if (existing) {
    return new Promise((resolve, reject) => {
      existing.addEventListener('load', () => resolve(), { once: true })
      existing.addEventListener('error', () => reject(new Error('Turnstile failed to load')), {
        once: true,
      })
    })
  }

  return new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.src = TURNSTILE_SCRIPT_SRC
    script.async = true
    script.defer = true
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('Turnstile failed to load'))
    document.head.appendChild(script)
  })
}

export default function ContactForm({ className }: ContactFormProps) {
  const formId = useId()
  const turnstileContainerRef = useRef<HTMLDivElement>(null)
  const widgetIdRef = useRef<string | undefined>(undefined)
  const [turnstileToken, setTurnstileToken] = useState('')
  const [formState, setFormState] = useState<FormState>('idle')
  const [errorMessage, setErrorMessage] = useState('')
  const siteKey = getTurnstileSiteKey()

  const resetTurnstile = useCallback(() => {
    setTurnstileToken('')
    if (widgetIdRef.current && window.turnstile) {
      window.turnstile.reset(widgetIdRef.current)
    }
  }, [])

  useEffect(() => {
    if (!siteKey || !turnstileContainerRef.current) {
      return undefined
    }

    let cancelled = false

    loadTurnstileScript()
      .then(() => {
        if (cancelled || !turnstileContainerRef.current || !window.turnstile) {
          return
        }
        widgetIdRef.current = window.turnstile.render(turnstileContainerRef.current, {
          sitekey: siteKey,
          theme: 'auto',
          callback: (token) => setTurnstileToken(token),
          'expired-callback': () => setTurnstileToken(''),
          'error-callback': () => setTurnstileToken(''),
        })
      })
      .catch(() => {
        if (!cancelled) {
          setErrorMessage('Security verification could not be loaded. Please try again later.')
        }
      })

    return () => {
      cancelled = true
      if (widgetIdRef.current && window.turnstile) {
        window.turnstile.remove(widgetIdRef.current)
        widgetIdRef.current = undefined
      }
    }
  }, [siteKey])

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setErrorMessage('')

    if (!siteKey) {
      setFormState('error')
      setErrorMessage('Contact form is not configured. Please use the email addresses below.')
      return
    }

    if (!turnstileToken) {
      setFormState('error')
      setErrorMessage('Please complete the security verification.')
      return
    }

    const form = event.currentTarget
    const formData = new FormData(form)
    const payload = {
      name: String(formData.get('name') ?? '').trim(),
      email: String(formData.get('email') ?? '').trim(),
      topic: String(formData.get('topic') ?? '').trim(),
      message: String(formData.get('message') ?? '').trim(),
      website: String(formData.get('website') ?? '').trim(),
      turnstileToken,
    }

    setFormState('submitting')

    try {
      const response = await fetch(API_CONTACT_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })

      if (!response.ok) {
        const body = (await response.json().catch(() => null)) as {
          error?: { message?: string }
        } | null
        throw new Error(body?.error?.message ?? 'Unable to send your message. Please try again.')
      }

      form.reset()
      resetTurnstile()
      setFormState('success')
    } catch (error) {
      setFormState('error')
      setErrorMessage(
        error instanceof Error ? error.message : 'Unable to send your message. Please try again.',
      )
      resetTurnstile()
    }
  }

  return (
    <section
      className={className ? `contact-form-section ${className}` : 'contact-form-section'}
      aria-labelledby={`${formId}-heading`}
    >
      <h2 className="legal-section-title" id={`${formId}-heading`}>
        Send a message
      </h2>
      <p className="legal-section-lead">
        Messages are delivered to the CryPrice team. For security vulnerabilities, prefer{' '}
        <a href="mailto:security@cryprice.dev">security@cryprice.dev</a> or the{' '}
        <a href="/security/">security model</a>.
      </p>

      <form className="contact-form" onSubmit={handleSubmit} noValidate>
        <div className="contact-form-field contact-form-field--honeypot" aria-hidden="true">
          <label htmlFor={`${formId}-website`}>Website</label>
          <input id={`${formId}-website`} name="website" type="text" tabIndex={-1} autoComplete="off" />
        </div>

        <div className="contact-form-field">
          <label htmlFor={`${formId}-name`}>Name</label>
          <input
            id={`${formId}-name`}
            name="name"
            type="text"
            required
            autoComplete="name"
            maxLength={120}
          />
        </div>

        <div className="contact-form-field">
          <label htmlFor={`${formId}-email`}>Email</label>
          <input
            id={`${formId}-email`}
            name="email"
            type="email"
            required
            autoComplete="email"
            maxLength={254}
          />
        </div>

        <div className="contact-form-field">
          <label htmlFor={`${formId}-topic`}>Topic</label>
          <select id={`${formId}-topic`} name="topic" required defaultValue="support">
            {CONTACT_FORM_TOPICS.map((topic) => (
              <option key={topic.value} value={topic.value}>
                {topic.label}
              </option>
            ))}
          </select>
        </div>

        <div className="contact-form-field">
          <label htmlFor={`${formId}-message`}>Message</label>
          <textarea
            id={`${formId}-message`}
            name="message"
            required
            rows={6}
            minLength={10}
            maxLength={5000}
          />
        </div>

        {siteKey ? (
          <div className="contact-form-field contact-form-turnstile">
            <div ref={turnstileContainerRef} />
          </div>
        ) : (
          <p className="contact-form-note" role="status">
            The contact form is temporarily unavailable. Please use the email addresses below.
          </p>
        )}

        {formState === 'success' ? (
          <p className="contact-form-status contact-form-status--success" role="status">
            Thank you — your message was sent. We will respond when feasible.
          </p>
        ) : null}

        {formState === 'error' && errorMessage ? (
          <p className="contact-form-status contact-form-status--error" role="alert">
            {errorMessage}
          </p>
        ) : null}

        <button
          type="submit"
          className="btn btn--primary"
          disabled={formState === 'submitting' || !siteKey}
        >
          {formState === 'submitting' ? 'Sending…' : 'Send message'}
        </button>
      </form>
    </section>
  )
}
