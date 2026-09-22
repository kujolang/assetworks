# AssetWorks

[![Version](https://img.shields.io/badge/version-0.3.0-black)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![built with Kujo](https://img.shields.io/badge/built%20with-Kujo-white.svg)](https://github.com/kujolang/kujo)
[![CI](https://github.com/kujolang/assetworks/actions/workflows/validate.yml/badge.svg)](https://github.com/kujolang/assetworks/actions/workflows/validate.yml)

AssetWorks is a local-first Kujo tool for media asset planning, immutable provenance, accessibility artifacts, and checksum-backed validation. It has no required hosted service, database server, model key, or sibling-tool dependency.

## What works today

Plan media work, record transformation intents, bind files to manifests and accessibility records, inspect and export local records, and validate attached file checksums. Core commands run offline in Kujo, with no required hosted service or model credentials. Transform commands record a planned intent by default. With an explicit [FFmpeg adapter configuration](docs/ADAPTERS.md), they execute bounded offline conversions, probe the generated artifact and record a completed receipt. Optional [container isolation](docs/ISOLATION.md) confines codecs and probes with no network or host mounts.

Records have stable IDs, actors, timestamps and append-only creation events. Storage uses immutable transaction journals and atomic no-replace writes. Validation reconciles exact record bytes with their creation events and detects orphan events. [Recovery](docs/RECOVERY.md) replays interrupted transactions without overwriting existing evidence. This remains an operator-controlled local tool, not a hosted multi-tenant service.

Optional [RSA public-key signatures or shared-key HMAC authentication](docs/AUTHENTICATION.md) sign complete manifest records. Public verification uses an explicit rotation/revocation trust store. [Confined streaming checksums](docs/LARGE_FILES.md) support explicitly bounded attachments up to 4 GiB. The adapter has a separate 8 MiB input/output limit.

[Sharded collections and migration](docs/STORAGE_LAYOUT.md) support larger local state without a mutable index. [Backup and restore](docs/BACKUP_RESTORE.md) preserve immutable signatures and referenced media across loss of the original volume.

See the [blocker follow-up and next-session opportunities](docs/REVIEW_FOLLOWUP_2026-09-22.md), following the [September review](docs/REVIEW_2026-09-22.md). The [previous review](docs/PRODUCTION_READINESS_REVIEW.md) and [August checklist](docs/NEXT_SESSION.md) are historical.

## Quick install

This development version requires the Kujo 1.5.0 candidate with confined filesystem primitives. CI pins source revision `a0d433e9aba27208a59927519c529d10f1f87f06`; use that build for reproducibility rather than assuming every older runtime binary includes these APIs. The [format/signature Linux/macOS/Windows suite](https://github.com/kujolang/assetworks/actions/runs/35776897250) passes at `dcf8282`, including 235 assertions per platform, real media adapters and concurrency checks. See the [blocker follow-up](docs/REVIEW_FOLLOWUP_2026-09-22.md) for limits, benchmarks and next-session opportunities.

Build the pinned runtime in a separate checkout (Rust and the platform dependencies described in [Kujo's source-build guide](https://github.com/kujolang/kujo/blob/a0d433e9aba27208a59927519c529d10f1f87f06/README.md#build-and-test-from-source) are required):

```bash
git clone https://github.com/kujolang/kujo.git assetworks-runtime
git -C assetworks-runtime checkout a0d433e9aba27208a59927519c529d10f1f87f06
cargo build --release --locked --manifest-path assetworks-runtime/Cargo.toml
export KUJO_BIN="$PWD/assetworks-runtime/target/release/kujo"
```

On Windows the executable ends in `.exe`; [the CI workflow](.github/workflows/validate.yml) includes the OpenSSL setup and complete verification recipe.

```bash
git clone https://github.com/kujolang/assetworks.git
cd assetworks
export PATH="$PWD/bin:$PATH"
assetworks --version --json
assetworks doctor --json
```

## Quick start

```bash
assetworks init --state .assetworks --json
assetworks plan --input fixtures/core.json --actor producer --json
assetworks validate --json
assetworks export --output assetworks-export.json --json
```

Run `assetworks --help` for the complete command surface. Common flags include `--state`, `--config`, `--input`, `--actor`, `--timestamp`, `--id`, `--path`, `--type`, `--after`, `--limit`, `--output`, `--force`, `--dry-run`, and `--json`. JSON mode uses the stable `ok/data/error/error_code/tool_version/contract_version` envelope. Exit codes are 0 success, 1 operational failure, and 2 usage error.

State defaults to `.assetworks/`. Use operator-controlled directories and canonical paths without symlinked ancestors. Inputs and individual records are capped at 1 MiB; CLI attachments default to 64 MiB; `--max-artifact-bytes` explicitly raises the limit up to 4 GiB. `--dry-run` validates a proposed record without creating state. It does not reserve an ID.

Lists and exports inspect at most 1,000 JSON filenames per page and enforce aggregate byte budgets. Resume using the returned `next_after`, even on an empty filtered page. [Whole-state validation has three independent resumable cursors](docs/PAGINATION.md) and never reports an unfinished audit as complete. Doctor remains a bounded first-page diagnostic. Exports into the active state directory are refused even with `--force`. Case-equivalent state names are conservatively reserved across platforms.

Validation checks attached-file drift, exact record/event checksums, orphan events and transaction completeness. Unsigned evidence cannot authenticate an operator who can rewrite all state files. HMAC verification adds authenticity only when the shared key remains protected separately from state; public signatures require separately trusted public keys and an explicit revocation policy. `history` lists creation events and accepts its returned event cursor with `--after`.

For a complete runnable plan → manifest → captions/transcript → validate → export example, see [the licensed media walkthrough](examples/README.md).

## Project structure

```text
assetworks.kujo       canonical entrypoint
src/                  CLI, domain, storage, and shared Kujo modules
tests/                regression, security, and domain suites
schemas/              public JSON contracts
fixtures/             deterministic offline inputs
scripts/              validation gates
docs/                 contracts, security, review, and future work
bin/assetworks        logic-free launcher
```

## Verification

```bash
FFMPEG_BIN=/absolute/path/to/ffmpeg FFPROBE_BIN=/absolute/path/to/ffprobe \
ASSETWORKS_REQUIRE_ADAPTER_TESTS=1 KUJO_BIN=/absolute/path/to/kujo bash scripts/validate.sh
```

The gate checks the entrypoint, Kujo suites, real FFmpeg conversions, JSON artifacts, CLI smoke paths, distinct-ID and same-ID contention, foreign-runtime boundaries, and the Git diff. Omit the FFmpeg variables only for a core-only local run; CI requires the adapter suite.

## Explore the Kujo implementation

Start with [the two-line entrypoint](assetworks.kujo), then [CLI orchestration](src/core.kujo), [domain rules](src/domain.kujo), and [storage](src/storage.kujo). The [Kujo language repository](https://github.com/kujolang/kujo) provides the runtime and language documentation. Runtime logic and regression assertions stay in Kujo; shell scripts only launch and coordinate checks.
