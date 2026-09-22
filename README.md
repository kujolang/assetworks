# AssetWorks

[![Version](https://img.shields.io/badge/version-0.2.0-black)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![built with Kujo](https://img.shields.io/badge/built%20with-Kujo-white.svg)](https://github.com/kujolang/kujo)
[![CI](https://github.com/kujolang/assetworks/actions/workflows/validate.yml/badge.svg)](https://github.com/kujolang/assetworks/actions/workflows/validate.yml)

AssetWorks is a local-first Kujo tool for media asset planning, immutable provenance, accessibility artifacts, and checksum-backed validation. It has no required hosted service, database server, model key, or sibling-tool dependency.

## What works today

Plan media work, record transformation intents, bind files to manifests and accessibility records, inspect and export local records, and validate attached file checksums. Core commands run offline in Kujo, with no required hosted service or model credentials. Transform commands record intent; they do not execute FFmpeg or an image processor.

Records have stable IDs, actors, timestamps and append-only creation events. Storage uses immutable transaction journals and atomic no-replace writes. Validation reconciles exact record bytes with their creation events and detects orphan events. [Recovery](docs/RECOVERY.md) replays interrupted transactions without overwriting existing evidence. This remains an operator-controlled local tool, not a hosted multi-tenant service.

Standalone library helpers cover adapter receipts, probe metadata, bounded large-file hashing and shared-key HMAC authentication. They are not integrated CLI capabilities, and the current tests do not establish multi-gigabyte performance.

See the [September review and prioritized next-session worklist](docs/REVIEW_2026-09-22.md). The [previous review](docs/PRODUCTION_READINESS_REVIEW.md) and [August checklist](docs/NEXT_SESSION.md) are historical.

## Quick install

This development version requires Kujo 1.4.0 with confined filesystem primitives. CI pins source revision `599866bef0beb042c07751b77aa538db7f1a696c`; use that build for reproducibility rather than assuming every binary labeled 1.4.0 includes these preview APIs. Full-suite Linux/macOS/Windows verification is in progress.

```bash
git clone https://github.com/kujolang/assetworks.git
cd assetworks
export KUJO_BIN=/absolute/path/to/kujo
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

State defaults to `.assetworks/`. Use operator-controlled directories and canonical paths without symlinked ancestors. Inputs and individual records are capped at 1 MiB; CLI attachments are capped at 64 MiB. `--dry-run` validates a proposed record without creating state. It does not reserve an ID.

Lists and exports return at most 1,000 records; paginate with `--after` using the last returned ID. Doctor and whole-state validation fail with an incomplete result if more records exist. Validate additional records individually with `--id`. Exports into the active state directory are refused even with `--force`. Case-equivalent state names are conservatively reserved across platforms.

Validation checks attached-file drift, exact record/event checksums, orphan events and transaction completeness. It does not authenticate evidence against an operator who can rewrite all state files. `history` lists creation events and accepts its returned event cursor with `--after`.

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
KUJO_BIN=/absolute/path/to/kujo bash scripts/validate.sh
```

The gate checks the entrypoint, every Kujo suite, JSON artifacts, CLI smoke paths, foreign-runtime boundaries, and the Git diff.

## Explore the Kujo implementation

Start with [the two-line entrypoint](assetworks.kujo), then [CLI orchestration](src/core.kujo), [domain rules](src/domain.kujo), and [storage](src/storage.kujo). The [Kujo language repository](https://github.com/kujolang/kujo) provides the runtime and language documentation. Runtime logic and regression assertions stay in Kujo; shell scripts only launch and coordinate checks.
