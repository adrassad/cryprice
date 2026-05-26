# Security Policy

## Reporting a vulnerability

If you discover a security issue in this public repository or the documented public API surface, please report it responsibly:

**Email:** [security@cryprice.dev](mailto:security@cryprice.dev)

Please include:

- A clear description of the issue
- Steps to reproduce (if applicable)
- Impact assessment
- Your contact information (optional, for follow-up)

We ask that you **do not** publicly disclose the issue until we have had a reasonable opportunity to investigate and respond.

There is **no bug bounty program** at this time.

## Scope

In scope:

- Code in this public repository (`https://github.com/adrassad/cryprice`)
- Public API and client examples documented in this repository
- Security model and setup documentation in `docs/`

Out of scope:

- Social engineering attacks
- Spam or denial-of-service against third-party infrastructure
- Physical attacks
- Third-party services not controlled by CryPrice (Google OAuth, Telegram, RPC providers, hosting providers, etc.)
- Financial loss claims arising from market or trading decisions
- Issues in private repositories or production infrastructure not published here

## Product security model

CryPrice is **read-only monitoring infrastructure**:

- CryPrice **does not custody funds**
- CryPrice **does not ask for private keys or seed phrases**
- CryPrice **does not execute transactions**
- Monitoring data is **informational only** — **not financial advice**

For the full security model, see [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md).

## Supported versions

Security fixes are applied to the `main` branch of this public repository. There are no long-term support branches published at this time.

## What to expect

We will acknowledge receipt of your report when possible and investigate valid issues affecting the public codebase. Response times may vary; this is an open-source project without a formal SLA.

Thank you for helping keep CryPrice and its users safe.
