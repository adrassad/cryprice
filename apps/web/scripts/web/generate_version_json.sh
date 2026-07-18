#!/usr/bin/env bash
# Writes web/version.json with deploy metadata and prints the build id to stdout.
#
# Usage:
#   BUILD_ID=$(./scripts/web/generate_version_json.sh)
#   AUTH_FLOW_VERSION=2 ./scripts/web/generate_version_json.sh
#
# Local dev: committed web/version.json keeps build "dev" unless this script is run.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION_FILE="${ROOT_DIR}/web/version.json"
AUTH_FLOW_VERSION="${AUTH_FLOW_VERSION:-2}"

BUILD_ID="dev"
COMMIT=""

if command -v git >/dev/null 2>&1 && git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BUILD_ID="$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
  COMMIT="$(git -C "$ROOT_DIR" rev-parse HEAD)"
fi

BUILT_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [[ -n "$COMMIT" ]]; then
  cat >"$VERSION_FILE" <<EOF
{
  "app": "cryprice-web",
  "build": "${BUILD_ID}",
  "commit": "${COMMIT}",
  "builtAt": "${BUILT_AT}",
  "authFlowVersion": ${AUTH_FLOW_VERSION}
}
EOF
else
  cat >"$VERSION_FILE" <<EOF
{
  "app": "cryprice-web",
  "build": "${BUILD_ID}",
  "builtAt": "${BUILT_AT}",
  "authFlowVersion": ${AUTH_FLOW_VERSION}
}
EOF
fi

echo "Wrote ${VERSION_FILE} (build=${BUILD_ID}, authFlowVersion=${AUTH_FLOW_VERSION})" >&2
echo "${BUILD_ID}"
