# AssetWorks

[![Version](https://img.shields.io/badge/version-0.2.0-black)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![built with Kujo](https://img.shields.io/badge/built%20with-Kujo-white.svg)](https://github.com/kujolang/kujo)
[![CI](https://github.com/kujolang/assetworks/actions/workflows/validate.yml/badge.svg)](https://github.com/kujolang/assetworks/actions/workflows/validate.yml)

AssetWorks is a local-first Kujo tool for media asset planning, immutable provenance, accessibility artifacts, and checksum-backed validation. It has no required hosted service, database server, model key, or sibling-tool dependency.

## What works today

Plan media work, record transformation intents, bind files to manifests and accessibility records, inspect and export local records, and validate attached file checksums. Core commands run offline in Kujo, with no required hosted service or model credentials. Transform commands record intent; they do not execute FFmpeg or an image processor.

Records have stable IDs, actors, timestamps and append-only creation events. Storage uses per-record locks and atomic individual file writes. This is an operator-controlled local tool: record/event crash recovery and audit reconciliation still need work before broader enterprise readiness claims.

Standalone library helpers cover adapter receipts, probe metadata, bounded large-file hashing and shared-key HMAC authentication. They are not integrated CLI capabilities, and the current tests do not establish multi-gigabyte performance.

See the [September review and prioritized next-session worklist](docs/REVIEW_2026-09-22.md). The [previous review](docs/PRODUCTION_READINESS_REVIEW.md) and [August checklist](docs/NEXT_SESSION.md) are historical.

## Quick install

The declared minimum is Kujo 1.0.1; this review was verified locally with Kujo 1.4.0 on macOS. Full-suite support across versions and platforms remains to be established.

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

Lists and exports return at most 1,000 records; paginate with `--after` using the last returned ID. Doctor and whole-state validation fail with an incomplete result if more records exist. Validate additional records individually with `--id`. Keep exports outside the state directory, especially when using `--force`.

Local checksum validation detects attached file drift; it does not yet authenticate the audit history or protect against an operator who can edit state files.

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
