#!/usr/bin/env bash
# Production Flutter Web build with synchronized deploy metadata.
#
# 1. Generates web/version.json (build id from git short SHA)
# 2. Compiles the same build id into the bundle via --dart-define=APP_BUILD_ID
#
# Usage:
#   ./scripts/web/build_release.sh
#   ./scripts/web/build_release.sh --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
#
# Extra flutter build args (e.g. other --dart-define values) are forwarded.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

export AUTH_FLOW_VERSION="${AUTH_FLOW_VERSION:-2}"

BUILD_ID="$(bash "${ROOT_DIR}/scripts/web/generate_version_json.sh")"

echo "Building Flutter web release (APP_BUILD_ID=${BUILD_ID}, AUTH_FLOW_VERSION=${AUTH_FLOW_VERSION})" >&2

flutter build web --release \
  --dart-define="APP_BUILD_ID=${BUILD_ID}" \
  --dart-define="AUTH_FLOW_VERSION=${AUTH_FLOW_VERSION}" \
  "$@"

bash "${ROOT_DIR}/scripts/web/generate_firebase_messaging_sw.sh" "${ROOT_DIR}/build/web" "$@"
bash "${ROOT_DIR}/scripts/web/inject_firebase_into_flutter_sw.sh" "${ROOT_DIR}/build/web"

echo "Output: ${ROOT_DIR}/build/web/ (version.json build=${BUILD_ID})" >&2
