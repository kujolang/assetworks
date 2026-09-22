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

See the [round-two review and next-session worklist](docs/REVIEW_FOLLOWUP_2026-09-22_ROUND_2.md) and [implementation/release acceptance checklist](docs/NEXT_SESSION_IMPLEMENTATION.md). The [blocker follow-up](docs/REVIEW_FOLLOWUP_2026-09-22.md), [September review](docs/REVIEW_2026-09-22.md), [previous review](docs/PRODUCTION_READINESS_REVIEW.md) and [August checklist](docs/NEXT_SESSION.md) preserve earlier evidence.

## Quick install

AssetWorks 0.3.0 requires **Kujo 1.5.0**. Download the matching native archive and checksum from [Kujo's release](https://github.com/kujolang/kujo/releases/tag/v1.5.0), verify the checksum, and extract the executable. Releases cover Linux and macOS on x64/ARM64, and Windows x64. On Windows, use Git Bash for the launcher and include `.exe` in `KUJO_BIN`.

```bash
export KUJO_BIN="/absolute/path/to/kujo"
git clone --branch v0.3.0 --depth 1 https://github.com/kujolang/assetworks.git
cd assetworks
export PATH="$PWD/bin:$PATH"
assetworks --version --json
assetworks doctor --json
```

A checksummed, self-contained source archive is also available from [AssetWorks 0.3.0](https://github.com/kujolang/assetworks/releases/tag/v0.3.0). The launcher preserves your working directory and loads its own modules. FFmpeg/FFprobe are optional dependencies for [media conversion](docs/ADAPTERS.md); planning and evidence workflows run without them.

To build Kujo from source instead, follow its [platform build prerequisites](https://github.com/kujolang/kujo/blob/v1.5.0/README.md#build-and-test-from-source) and use the release's immutable source revision:

```bash
git clone https://github.com/kujolang/kujo.git assetworks-runtime
git -C assetworks-runtime checkout cc2d7dbb59a8dc05f00d629e100932f56f4062f6
cargo build --release --locked --manifest-path assetworks-runtime/Cargo.toml
export KUJO_BIN="$PWD/assetworks-runtime/target/release/kujo"
```

The [full Linux/macOS/Windows regression matrix](https://github.com/kujolang/assetworks/actions/runs/35786822556) verifies 300 assertions per platform, real media adapters, concurrency and launcher behavior. Linux additionally verifies actual container boundaries and large-file/state measurements. See the [release acceptance record](docs/NEXT_SESSION_IMPLEMENTATION.md) for exact evidence and operating limits.

## Quick start

```bash
assetworks init --state .assetworks --json
assetworks plan --input fixtures/core.json --actor producer --json
assetworks validate --json
assetworks export --output assetworks-export.json --json
```

Run `assetworks --help` for the complete command surface. Common flags include `--state`, `--config`, `--input`, `--actor`, `--timestamp`, `--id`, `--path`, `--type`, `--after`, `--limit`, `--output`, `--force`, `--dry-run`, and `--json`. JSON mode uses the stable `ok/data/error/error_code/tool_version/contract_version` envelope. Exit codes are 0 success, 1 operational failure, and 2 usage error.

The launcher isolates its Kujo imports from the caller’s modules and lockfile while preserving the caller’s working directory for state and relative input paths.

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
