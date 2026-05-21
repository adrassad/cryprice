#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

FAILED=0

# This script and the sync policy may intentionally mention forbidden terms as examples.
GREP_EXCLUDE_META=(
  -- .
  -- ':!scripts/public-sync-check.sh'
  -- ':!docs/PUBLIC_SYNC_POLICY.md'
)

section() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

warn() {
  echo "⚠️  $1"
}

fail() {
  echo "❌ $1"
  FAILED=1
}

pass() {
  echo "✅ $1"
}

run_check_allow_empty() {
  local title="$1"
  shift

  section "$title"
  "$@" || true
}

run_validation() {
  local title="$1"
  shift

  section "$title"
  if "$@"; then
    pass "$title passed"
  else
    fail "$title failed"
  fi
}

section "CryPrice public sync safety check"
echo "Repository: $ROOT_DIR"
echo "Policy: docs/PUBLIC_SYNC_POLICY.md"
echo

if [[ ! -f "docs/PUBLIC_SYNC_POLICY.md" ]]; then
  fail "docs/PUBLIC_SYNC_POLICY.md is missing"
else
  pass "docs/PUBLIC_SYNC_POLICY.md exists"
fi

section "Git status"
git status --short || fail "git status failed"

section "Diff summary"
git diff --stat || true

section "Generated/local artifacts tracked by git"
ARTIFACTS="$(git ls-files | grep -E '(^|/)build/|local.properties|node_modules|dist/|\.dart_tool|coverage/' || true)"
if [[ -n "$ARTIFACTS" ]]; then
  echo "$ARTIFACTS"
  fail "Generated/local artifacts are tracked"
else
  pass "No generated/local artifacts tracked"
fi

section "backend-public references"
BACKEND_PUBLIC="$(git grep -F "backend-public" "${GREP_EXCLUDE_META[@]}" || true)"
if [[ -n "$BACKEND_PUBLIC" ]]; then
  echo "$BACKEND_PUBLIC"
  fail "Found backend-public references"
else
  pass "No backend-public references"
fi

section "Public Telegram / bot link checks"

AAVE_RADAR="$(git grep -n -F "AaveRadar" "${GREP_EXCLUDE_META[@]}" || true)"
if [[ -n "$AAVE_RADAR" ]]; then
  echo "$AAVE_RADAR"
  fail "Found AaveRadar references"
else
  pass "No AaveRadar references"
fi

TELEGRAM_LINKS="$(git grep -n -F "t.me/" \
  "${GREP_EXCLUDE_META[@]}" \
  -- ':!**/package-lock.json' || true)"
if [[ -n "$TELEGRAM_LINKS" ]]; then
  echo "$TELEGRAM_LINKS"

  DISALLOWED_TELEGRAM="$(echo "$TELEGRAM_LINKS" | grep -v "services/api/src/services/auth/auth.service.js" || true)"
  if [[ -n "$DISALLOWED_TELEGRAM" ]]; then
    echo "$DISALLOWED_TELEGRAM"
    fail "Found public Telegram links outside authenticated backend deep-link generation"
  else
    pass "Only authenticated backend Telegram deep-link remains"
  fi
else
  pass "No t.me links found"
fi

TELEGRAM_ME_LINKS="$(git grep -n -F "telegram.me/" \
  "${GREP_EXCLUDE_META[@]}" \
  -- ':!**/package-lock.json' || true)"
if [[ -n "$TELEGRAM_ME_LINKS" ]]; then
  echo "$TELEGRAM_ME_LINKS"
  fail "Found telegram.me links"
else
  pass "No telegram.me links"
fi

section "Active source payment/billing/subscription checks"

ACTIVE_PAYMENT_MATCHES="$(git grep -n -i -E "payment|billing|stripe|checkout|paid plan|paid-plan|upgrade|premium|subscription" \
  -- . \
  -- ':!*.md' \
  -- ':!**/package-lock.json' \
  -- ':!.github/workflows/**' \
  -- ':!services/api/src/blockchain/abi/**' \
  -- ':!scripts/public-sync-check.sh' \
  -- ':!docs/PUBLIC_SYNC_POLICY.md' \
  -- ':!apps/web/ios/**' \
  -- ':!apps/web/macos/**' \
  -- ':!apps/web/.metadata' || true)"

if [[ -n "$ACTIVE_PAYMENT_MATCHES" ]]; then
  echo "$ACTIVE_PAYMENT_MATCHES"

  REAL_ACTIVE_PAYMENT_MATCHES="$(echo "$ACTIVE_PAYMENT_MATCHES" | \
    grep -v "StreamSubscription" | \
    grep -v "LastUpgradeCheck" | \
    grep -v "LastUpgradeVersion" | \
    grep -v "perform upgrades" | \
    grep -v "admin/payment code removed" || true)"
  if [[ -n "$REAL_ACTIVE_PAYMENT_MATCHES" ]]; then
    echo "$REAL_ACTIVE_PAYMENT_MATCHES"
    fail "Found payment/billing/subscription terms in active source"
  else
    pass "Only known false positives found in active source payment/subscription scan"
  fi
else
  pass "No active payment/billing/subscription source matches"
fi

section "Backend active source payment/billing/subscription checks"

BACKEND_PAYMENT_MATCHES="$(git grep -n -i -E "payment|billing|stripe|checkout|paid plan|paid-plan|upgrade|premium|subscription" \
  -- services/api/src \
  ':!services/api/src/blockchain/abi/**' || true)"

if [[ -n "$BACKEND_PAYMENT_MATCHES" ]]; then
  echo "$BACKEND_PAYMENT_MATCHES"
  fail "Found payment/billing/subscription terms in backend active source"
else
  pass "No backend active payment/billing/subscription matches"
fi

section "Frontend active source payment/billing/subscription checks"

FRONTEND_PAYMENT_MATCHES="$(git grep -n -i -E "payment|billing|stripe|checkout|paid plan|paid-plan|upgrade|premium|subscription" \
  -- apps/web/lib apps/web/test || true)"

if [[ -n "$FRONTEND_PAYMENT_MATCHES" ]]; then
  echo "$FRONTEND_PAYMENT_MATCHES"

  FRONTEND_REAL_MATCHES="$(echo "$FRONTEND_PAYMENT_MATCHES" | grep -v "StreamSubscription" || true)"
  if [[ -n "$FRONTEND_REAL_MATCHES" ]]; then
    fail "Found payment/billing/subscription terms in frontend active source"
  else
    pass "Only Dart StreamSubscription false positive found"
  fi
else
  pass "No frontend active payment/billing/subscription matches"
fi

section "Admin/private module checks"

ADMIN_MATCHES="$(git grep -n -E "ADMIN_ID|admin.guard|upgradetopro|upgrade.handler|payments_pending|getAllProUsers|subscription.service" \
  -- . \
  -- ':!*.md' \
  -- ':!scripts/public-sync-check.sh' \
  -- ':!docs/PUBLIC_SYNC_POLICY.md' || true)"

if [[ -n "$ADMIN_MATCHES" ]]; then
  echo "$ADMIN_MATCHES"
  fail "Found admin/private module references outside markdown docs"
else
  pass "No admin/private module references outside markdown docs"
fi

section "Secret placeholder / real value scan"

SECRET_MATCHES="$(git grep -n -E "PRIVATE_KEY|JWT_ACCESS_SECRET|JWT_REFRESH_SECRET|BOT_TOKEN|GOOGLE_CLIENT_SECRET|GEMINI_API_KEY|OPENAI_API_KEY|DATABASE_URL|REDIS_PASSWORD|RPC_URL|EXPLORER_KEY" \
  "${GREP_EXCLUDE_META[@]}" || true)"

if [[ -n "$SECRET_MATCHES" ]]; then
  echo "$SECRET_MATCHES"
  warn "Review the matches above. Placeholder names, process.env reads, docs, tests, and CI dummy values are allowed. Real values are NOT allowed."
else
  pass "No secret-related terms found"
fi

section "Deployment/private infrastructure scan"

DEPLOY_MATCHES="$(git grep -n -i -E "root@|deploy@|ssh|pm2|nginx|systemd|/var/www|/var/lib|server_name|ssl_certificate" \
  "${GREP_EXCLUDE_META[@]}" || true)"

if [[ -n "$DEPLOY_MATCHES" ]]; then
  echo "$DEPLOY_MATCHES"
  warn "Review deployment/private infrastructure matches. Generic docs may be OK; real hosts/paths/users are not."
else
  pass "No deployment/private infrastructure matches"
fi

section "Markdown documentation sanity checks"

DOC_FORBIDDEN="$(git grep -n -i -E "O-1|USCIS|visa|immigration|extraordinary ability|evidence trail" \
  -- '*.md' \
  -- ':!docs/PUBLIC_SYNC_POLICY.md' || true)"
if [[ -n "$DOC_FORBIDDEN" ]]; then
  echo "$DOC_FORBIDDEN"
  fail "Found immigration/O-1 wording in markdown docs"
else
  pass "No O-1/visa/immigration wording in markdown docs"
fi

DOC_BACKEND_PUBLIC="$(git grep -n -F "backend-public" \
  -- '*.md' \
  -- ':!docs/PUBLIC_SYNC_POLICY.md' || true)"
if [[ -n "$DOC_BACKEND_PUBLIC" ]]; then
  echo "$DOC_BACKEND_PUBLIC"
  fail "Found backend-public wording in markdown docs"
else
  pass "No backend-public wording in markdown docs"
fi

section "Lockfile review"
find . -name "package-lock.json" -not -path "./apps/marketing/package-lock.json" -not -path "./services/api/package-lock.json" -print | while read -r lockfile; do
  warn "Unexpected package-lock.json: $lockfile"
done

if [[ -f "apps/marketing/package-lock.json" ]]; then
  pass "apps/marketing/package-lock.json exists"
fi

if [[ -f "services/api/package-lock.json" ]]; then
  pass "services/api/package-lock.json exists"
else
  warn "services/api/package-lock.json is missing. This may be OK if API intentionally uses npm install without lockfile."
fi

section "Validation: apps/marketing"
if [[ -d "apps/marketing" ]]; then
  (
    cd apps/marketing || exit 1
    npm run lint && npm run build
  )
  if [[ $? -eq 0 ]]; then
    pass "Marketing validation passed"
  else
    fail "Marketing validation failed"
  fi
else
  fail "apps/marketing directory missing"
fi

section "Validation: services/api"
if [[ -d "services/api" ]]; then
  (
    cd services/api || exit 1
    DATABASE_URL=postgres://test:test@localhost:5432/cryprice_test \
    BOT_TOKEN=test-token-for-ci \
    JWT_ACCESS_SECRET=test-jwt-access-secret-at-least-32-chars \
    npm test && npm run build
  )
  if [[ $? -eq 0 ]]; then
    pass "API validation passed"
  else
    fail "API validation failed"
  fi
else
  fail "services/api directory missing"
fi

section "Validation: apps/web"
if [[ -d "apps/web" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    (
      cd apps/web || exit 1
      flutter gen-l10n && flutter analyze && flutter test
    )
    if [[ $? -eq 0 ]]; then
      pass "Flutter validation passed"
    else
      fail "Flutter validation failed"
    fi
  else
    warn "Flutter is not installed or not in PATH. Skipping Flutter validation."
  fi
else
  fail "apps/web directory missing"
fi

section "Validation: packages/shared"
if [[ -d "packages/shared" ]]; then
  (
    cd packages/shared || exit 1
    npm run typecheck
  )
  if [[ $? -eq 0 ]]; then
    pass "packages/shared typecheck passed"
  else
    fail "packages/shared typecheck failed"
  fi
else
  warn "packages/shared directory missing"
fi

section "Validation: packages/api-client"
if [[ -d "packages/api-client" ]]; then
  (
    cd packages/api-client || exit 1
    npm run typecheck
  )
  if [[ $? -eq 0 ]]; then
    pass "packages/api-client typecheck passed"
  else
    fail "packages/api-client typecheck failed"
  fi
else
  warn "packages/api-client directory missing"
fi

section "Final git status"
git status --short || true

echo
echo "============================================================"
if [[ "$FAILED" -eq 0 ]]; then
  echo "✅ Public sync check completed successfully."
  echo "Recommended next steps:"
  echo "  git add -A"
  echo "  git status"
  echo "  git commit -m \"Sync sanitized public edition\""
  echo "  git push origin main"
else
  echo "❌ Public sync check found issues. Fix them before committing."
fi
echo "============================================================"

exit "$FAILED"
