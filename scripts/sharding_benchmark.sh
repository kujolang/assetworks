#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO_RUNTIME="${KUJO_BIN:?set KUJO_BIN explicitly}"
if [[ ! -x "$KUJO_RUNTIME" && -x "$KUJO_RUNTIME.exe" ]]; then KUJO_RUNTIME="$KUJO_RUNTIME.exe"; fi
COUNT="${1:-100001}"
BENCH_TMP="$(mktemp -d)"
BENCH_TMP="$(cd "$BENCH_TMP" && pwd -P)"
trap 'find "$BENCH_TMP" -depth -delete' EXIT
cd "$ROOT"
for phase in prepare migrate inspect; do
  "$KUJO_RUNTIME" run scripts/sharding_benchmark.kujo -- "$phase" "$BENCH_TMP" "$COUNT"
done
