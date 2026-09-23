#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO_RUNTIME="${KUJO_BIN:?set KUJO_BIN explicitly}"
COUNT="${1:-1001}"
BENCH_TMP="$(mktemp -d)"
BENCH_TMP="$(cd "$BENCH_TMP" && pwd -P)"
trap 'find "$BENCH_TMP" -depth -delete' EXIT
cd "$ROOT"
for distribution in uniform skewed; do
  for phase in prepare measure; do
    "$KUJO_RUNTIME" run scripts/operating_benchmark.kujo -- "$phase" "$BENCH_TMP" "$COUNT" "$distribution"
  done
done
