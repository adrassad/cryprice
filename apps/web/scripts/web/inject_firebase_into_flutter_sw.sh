#!/usr/bin/env bash
# Prepends importScripts('firebase-messaging-sw.js') to flutter_service_worker.js.
#
# Idempotent: does not duplicate the import line on re-run.
#
# Usage:
#   ./scripts/web/inject_firebase_into_flutter_sw.sh [build/web]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_WEB_DIR="${1:-${ROOT_DIR}/build/web}"

FLUTTER_SW="${BUILD_WEB_DIR}/flutter_service_worker.js"
FCM_SW="${BUILD_WEB_DIR}/firebase-messaging-sw.js"
IMPORT_LINE="importScripts('firebase-messaging-sw.js');"

if [[ ! -f "${FLUTTER_SW}" ]]; then
  echo "[inject_firebase_into_flutter_sw] skipped — ${FLUTTER_SW} not found" >&2
  exit 0
fi

if [[ ! -f "${FCM_SW}" ]]; then
  echo "[inject_firebase_into_flutter_sw] skipped — ${FCM_SW} not found (no FCM config)" >&2
  exit 0
fi

if grep -qF "${IMPORT_LINE}" "${FLUTTER_SW}"; then
  chmod 644 "${FLUTTER_SW}"
  echo "[inject_firebase_into_flutter_sw] already injected" >&2
  exit 0
fi

TMP="$(mktemp)"
{
  echo "${IMPORT_LINE}"
  cat "${FLUTTER_SW}"
} >"${TMP}"
mv "${TMP}" "${FLUTTER_SW}"
chmod 644 "${FLUTTER_SW}"

echo "[inject_firebase_into_flutter_sw] injected into ${FLUTTER_SW}" >&2
