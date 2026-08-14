# AssetWorks

Controlled media inspection, production jobs, variants, captions, transcripts, accessibility, provenance, and manifests.

AssetWorks 0.1.0 is an independently installable, local-first Kujo tool. It requires no hosted service, Chain of Command, WebOps, or sibling Publishing House tool. The canonical entrypoint is `assetworks.kujo`; `bin/assetworks` contains no product logic.

## CLI

Commands: plan; inspect; render; convert; resize; captions; transcript; thumbnail; validate; manifest; report; doctor; version; init; show; export; history. Run `./bin/assetworks help` for flags. Mutations require `--actor`; JSON input uses `--input`. Common flags include `--json`, `--dry-run`, `--state`, `--output`, `--config`, and `--force`. Exit codes: 0 success, 1 validation/operation failure, 2 usage error.

State defaults to `.assetworks/`. Immutable JSON records and append-only history use atomic writes. IDs reject traversal; symlinks and oversized inputs are rejected. See [contracts](docs/contracts.md), [security](docs/security.md), and [quickstart](examples/quickstart.md).

Test with `/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo run tests/test.kujo`, then run `./bin/assetworks doctor --json`.

0.1.0 covers the documented local records, fixtures, validation, checksums, deterministic fixed-time IDs, and structured export. It does not manufacture human judgment, consent, rights, approval, or causation. Kujo 1.0.1 directly supports file validation, checksums, copying, manifests, captions, transcripts, and provenance; codec transforms, pixel resize, thumbnail rendering, and media probing are unavailable without explicit optional adapters.
