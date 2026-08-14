#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO_RUNTIME="${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}"
if [[ ! -x "$KUJO_RUNTIME" && -x "$KUJO_RUNTIME.exe" ]]; then KUJO_RUNTIME="$KUJO_RUNTIME.exe"; fi
STATE="$(mktemp -d)/state"
cleanup() { find "${STATE%/state}" -depth -delete; }
trap cleanup EXIT
for i in $(seq 1 32); do
  input="${STATE%/state}/input-$i.json"
  printf '{"schema_version":"1.0.0","source_id":"source-%s","operation":"probe","output_name":"output-%s"}\n' "$i" "$i" > "$input"
  KUJO_BIN="$KUJO_RUNTIME" "$ROOT/bin/assetworks" plan --state "$STATE" --input "$input" --actor benchmark --timestamp "2026-08-14T00:00:00Z" --id "plan-benchmark-$i" --json >/dev/null &
done
wait
count="$(find "$STATE/records" -type f -name 'plan-benchmark-*.json' | wc -l | tr -d ' ')"
test "$count" = 32
printf 'AssetWorks contention benchmark passed: platform=%s workers=32 records=%s\n' "$(uname -s)" "$count"
