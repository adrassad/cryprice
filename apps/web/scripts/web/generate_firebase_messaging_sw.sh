#!/usr/bin/env bash
# Generates build/web/firebase-messaging-sw.js from template + Firebase Web config.
#
# Config sources (first non-empty wins per key):
#   1. Environment: FIREBASE_PROJECT_ID, FIREBASE_MESSAGING_SENDER_ID,
#      FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID
#   2. --dart-define=FIREBASE_*=... from forwarded flutter build args
#
# Usage:
#   ./scripts/web/generate_firebase_messaging_sw.sh [build/web] [--dart-define=...]
#
# When all four values are missing, skips generation (web push disabled).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_WEB_DIR="${1:-${ROOT_DIR}/build/web}"
shift || true

TEMPLATE="${ROOT_DIR}/scripts/web/firebase_messaging_sw.template.js"
OUTPUT="${BUILD_WEB_DIR}/firebase-messaging-sw.js"

read_dart_define() {
  local key="$1"
  local arg
  for arg in "$@"; do
    case "${arg}" in
      --dart-define="${key}"=*)
        echo "${arg#--dart-define=${key}=}"
        return 0
        ;;
    esac
  done
  return 1
}

resolve_config() {
  local key="$1"
  shift
  local env_val="${!key:-}"
  if [[ -n "${env_val}" ]]; then
    echo "${env_val}"
    return 0
  fi
  read_dart_define "${key}" "$@" || true
}

FIREBASE_PROJECT_ID="$(resolve_config FIREBASE_PROJECT_ID "$@")"
FIREBASE_MESSAGING_SENDER_ID="$(resolve_config FIREBASE_MESSAGING_SENDER_ID "$@")"
FIREBASE_WEB_API_KEY="$(resolve_config FIREBASE_WEB_API_KEY "$@")"
FIREBASE_WEB_APP_ID="$(resolve_config FIREBASE_WEB_APP_ID "$@")"

if [[ -z "${FIREBASE_PROJECT_ID}" || -z "${FIREBASE_MESSAGING_SENDER_ID}" || -z "${FIREBASE_WEB_API_KEY}" || -z "${FIREBASE_WEB_APP_ID}" ]]; then
  echo "[generate_firebase_messaging_sw] skipped — set FIREBASE_* env or --dart-define (web push disabled)" >&2
  rm -f "${OUTPUT}"
  exit 0
fi

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "Template not found: ${TEMPLATE}" >&2
  exit 1
fi

mkdir -p "${BUILD_WEB_DIR}"

sed \
  -e "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID}|g" \
  -e "s|__FIREBASE_MESSAGING_SENDER_ID__|${FIREBASE_MESSAGING_SENDER_ID}|g" \
  -e "s|__FIREBASE_WEB_API_KEY__|${FIREBASE_WEB_API_KEY}|g" \
  -e "s|__FIREBASE_WEB_APP_ID__|${FIREBASE_WEB_APP_ID}|g" \
  "${TEMPLATE}" >"${OUTPUT}"

chmod 644 "${OUTPUT}"

echo "[generate_firebase_messaging_sw] wrote ${OUTPUT}" >&2
