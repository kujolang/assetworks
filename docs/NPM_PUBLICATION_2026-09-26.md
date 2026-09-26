# npm runtime publication — September 26, 2026

Kujo 1.5.0 is published to npm. This closes the registry-publication part of the AssetWorks distribution blocker; it does not publish a new AssetWorks release.

The existing publisher [run 36271277076](https://github.com/kujolang/kujo/actions/runs/36271277076) was already in progress when verification began. It successfully published the five native packages and resolver from verified release artifact run `35787043614`, with `EXPECTED_VERSION=1.5.0`. No duplicate publication was dispatched. The workflow reported provenance statements for all six packages.

Independent registry lookups confirmed version 1.5.0 for each package:

- `@kujolang/kujo-runtime`
- `@kujolang/kujo-darwin-arm64`
- `@kujolang/kujo-darwin-x64`
- `@kujolang/kujo-linux-arm64`
- `@kujolang/kujo-linux-x64`
- `@kujolang/kujo-win32-x64`

Initial public lookups still returned 1.4.0/404 immediately after publication; later lookups succeeded. Verification waited for actual availability and did not republish or substitute credentials. The precise account-side authorization change that enabled publication was not inspected, so no particular token or trusted-publisher correction is asserted.

A clean local macOS x64 install with `--ignore-scripts --no-audit --no-fund` selected the bundled 1.5.0 native runtime. It reported `kujo 1.5.0` and passed the native AssetWorks installation smoke, including plan/audit, caller working-directory preservation and caller import isolation.

The full AssetWorks local validation gate passed all 577 assertions against this npm-installed runtime, along with both 32-worker contention checks, explicit real FFmpeg/FFprobe coverage and installed-launcher verification. The installed resolver and native manifests contain no preinstall/install/postinstall lifecycle scripts.

The [five-platform installed-package matrix](https://github.com/kujolang/kujo/actions/runs/36271395324) was dispatched for exact version 1.5.0. Linux x64, Linux ARM64 and Windows x64 passed. Hosted macOS x64 and ARM64 jobs remain queued for runners at this checkpoint; the complete hosted matrix is **pending**, not reported as passed. Local macOS x64 verification above is independent and does not cover ARM64. Inspect this run to close the remaining verification checkpoint; publication itself is confirmed.

The remaining deployment work is real-data recovery acceptance, codec adoption, and the optional automatic-trust policy decision in the [acceptance worksheet](DEPLOYMENT_ACCEPTANCE.md). Historical publication failures remain valid incident history; they no longer establish that version 1.5.0 is unavailable.
