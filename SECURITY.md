# Security Policy

CryPrice is a read-only DeFi risk intelligence platform. This document describes how to report security vulnerabilities affecting CryPrice public surfaces and this public repository.

## Scope

In scope:

- `https://cryprice.dev`
- `https://app.cryprice.dev`
- `https://api.cryprice.dev`
- Code in this public repository (`https://github.com/adrassad/cryprice`)
- Public API and client examples documented in this repository
- Security model and setup documentation in `docs/`

Out of scope:

- Social engineering attacks
- Denial-of-service / spam against third-party infrastructure
- Issues requiring access to other users' private data beyond what is necessary to demonstrate impact
- Vulnerabilities in third-party services outside CryPrice control (Google OAuth, Telegram, RPC providers, hosting providers, etc.)
- Financial loss claims arising from market or trading decisions
- Issues in private repositories or production infrastructure not published here

## Read-only guarantees

CryPrice is a read-only DeFi portfolio monitoring and risk intelligence platform for public blockchain addresses.

CryPrice:

- Does not require recovery phrases, private keys, or wallet signing credentials
- Never stores private keys
- Never signs transactions
- Never executes blockchain transactions
- Never takes custody of assets

Google OAuth is used only for CryPrice account access and is unrelated to wallet authentication.

Monitoring data is **informational only** — not financial advice. Full model: [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md).

## How to report

Email: **security@cryprice.dev**

Machine-readable contact file: https://cryprice.dev/.well-known/security.txt

Trust hub: https://cryprice.dev/trust

Please include:

- A clear description of the issue
- Affected URLs or components
- Steps to reproduce
- Your assessment of impact
- Optional contact information for follow-up

Do not open public GitHub issues with exploit details before we have had a reasonable opportunity to investigate.

There is **no bug bounty program** at this time.

## Expected response times

- Acknowledgment target: within 3 business days
- Initial triage target: within 10 business days for verified reports

These are targets, not guarantees of resolution or compensation.

## Safe harbor

Good-faith security research that follows this policy and avoids privacy violations, service degradation, and destructive testing is welcome.

## Supported versions

Security fixes for this public edition are applied to the `main` branch. There are no long-term support branches published at this time.

## Contact

- Security: security@cryprice.dev
- Support: support@cryprice.dev
- Website: https://cryprice.dev/security
- Support channels: [`SUPPORT.md`](SUPPORT.md)
