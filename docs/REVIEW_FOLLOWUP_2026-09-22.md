# AssetWorks blocker follow-up — 2026-09-22

This follows [the September review](REVIEW_2026-09-22.md). AssetWorks remains a local, operator-controlled media evidence tool. Its security boundaries, supported formats and resource limits are explicit; this review does not establish universal enterprise suitability or a hosted tenancy model.

## Implementation and evidence

| Item | Delivered | Evidence / remaining verification |
| --- | --- | --- |
| AW-01 | Exact saved-byte event reconciliation; separate immutable history; orphan, missing and malformed event detection; legacy record compatibility | `tests/integrity_test.kujo` passes locally. |
| AW-02 | Immutable no-replace transaction journals and idempotent `recover --id` | Real subprocess termination at all three publication boundaries, distinct-ID concurrency and one-winner same-ID concurrency pass locally. |
| AW-03 | Active state protected against forced exports, including aliases and absent descendants | Integrity and path suites pass; external exports remain supported. |
| AW-04 | Rooted no-follow metadata IO and bounded streaming artifact hashes; no whole-path reopen during hashing | Native tests cover final/intermediate/dangling links, FIFO rejection, retained handles and concurrent ancestor swaps. VM and interpreter enforce filesystem-read capability. |
| AW-05 | Bounded-memory directory pages, aggregate content budgets, explicit truncation, independent resumable validation cursors | Pagination suite covers empty filtered pages, malformed names, byte-budget boundaries and cursor continuation. 1k/10k/100k local fixtures pass; fresh-process 100k page peak RSS is 29,261,824 bytes. |
| AW-06 | Explicit FFmpeg adapter with bounded processes, logs, copied input, protocol allowlist, output probes and content-addressed artifacts | Twelve real conversion assertions pass locally. Platform conformance is required by CI. |
| AW-07 | CLI manifest HMAC with explicit separate keys; attachments optionally bounded through 4 GiB | Authentication, tampering, downgrade, key handling and streaming tests pass. 65 MiB, 1 GiB and 4 GiB manifest creation, validation and independent digest comparisons pass locally. |
| AW-08 | Strict config and persisted record shapes, mutation-only commands, numeric overflow rejection, UTC calendar checks, JSON usage envelopes and public schema tests | Contract and authentication suites include Unicode byte quotas and key-length checks. |
| AW-09 | Pinned source runtime, full three-platform suite, mandatory adapter tests and native boundary contracts | Clean-checkout local gate passes. Current Linux/macOS/Windows CI results pending. Earlier Windows run exposed link-fixture path handling; that setup was corrected. |
| AW-10 | Original CC0 samples and runnable plan → manifest → captions/transcript → validate → export walkthrough | Four records/events created, reconciled and exported locally. |

## Runtime and reproducibility

The source requirement is Kujo `4e987a4e10d4b45621805e5acb420de4c9824b90`, a published preview revision containing both confined streaming SHA-256 and bounded directory enumeration. An arbitrary binary labeled 1.4.0 is insufficient. The runtime work is available in [Kujo PR #10](https://github.com/kujolang/kujo/pull/10). AssetWorks pins the immutable source revision rather than waiting for a future runtime release.

Local native verification passed 16 confined filesystem unit tests, focused filesystem integration checks, digest VM/interpreter parity and directory-page capability checks. A broader reduced-feature integration run passed 87 of 88 tests: its database misuse test expected the database feature omitted from that build. That is a build-feature limitation, not a passing full-runtime result. Platform application CI builds the default runtime features. The pinned runtime also passed its [descriptor-relative filesystem conformance matrix on Linux, macOS and Windows](https://github.com/kujolang/kujo/actions/runs/35751023004).

The local complete gate passed 178 assertions from clean checkout `1f2478e`, including real adapters, Windows path normalization and schema/authentication changes; both contention scenarios and remaining gate checks passed. The subsequent artifact-error and prefix-cursor fixes passed the complete local gate at `57ba330` (182 assertions plus both contention scenarios and remaining checks). A final resource audit also confirmed that Kujo `len()` counts Unicode characters: record, journal, export and aggregate-read bounds now use `byte_length()`. Regression fixtures cover oversized Unicode records, multi-byte page budgets and exact export byte receipts. Exact final CI and benchmark receipts will be recorded after those runs finish.

## Measured limits

Local measurements below use an unoptimized Rust debug runtime on macOS x86_64. They are correctness and memory evidence, not release-throughput claims. Streaming fixtures are real logical sparse files with a nonzero header; every byte is hashed, but sparse fixtures do not measure cold-disk performance. Each run creates and validates a manifest and compares a separate reference digest.

| Artifact bytes | Manifest creation | Validation | Peak RSS |
| ---: | ---: | ---: | ---: |
| 68,157,440 | 7,389 ms | 7,178 ms | 31,125,504 bytes |
| 1,073,741,824 | 99,885 ms | 107,300 ms | 29,081,600 bytes |
| 4,294,967,296 | 587,284 ms | 433,000 ms | 29,335,552 bytes |

Fresh-process page measurements exclude fixture generation. Every first page read 63,400 content bytes, returned 300 matching records and reported 100 corrupt entries.

| Directory entries | First page | Second page | Peak RSS |
| ---: | ---: | ---: | ---: |
| 1,000 | 8,432 ms | 11 ms (empty) | 27,615,232 bytes |
| 10,000 | 8,924 ms | 8,409 ms | 29,302,784 bytes |
| 100,000 | 9,155 ms | 9,738 ms | 29,261,824 bytes |

The initial Linux release run (revision `a765831`, [CI run](https://github.com/kujolang/assetworks/actions/runs/35751403258)) passed the complete application suite and benchmarks. Streaming release results were:

| Artifact bytes | Manifest creation | Validation | Peak RSS |
| ---: | ---: | ---: | ---: |
| 68,157,440 | 65 ms | 61 ms | 30,146,560 bytes |
| 1,073,741,824 | 838 ms | 766 ms | 30,003,200 bytes |
| 4,294,967,296 | 3,298 ms | 3,029 ms | 29,741,056 bytes |

The first Linux scale-memory results were not accepted as isolated page measurements: a forked measurement child can inherit its fixture-generating parent's peak RSS. The corrected shell wrapper launches fixture preparation and measurement as sibling processes. Corrected optimized scale receipts remain pending. See [pagination](PAGINATION.md) and [large files](LARGE_FILES.md) for exact commands and interpretation.

## Next-session opportunities

These are optional extensions beyond the bounded local deployment model, rather than assertions that AssetWorks already provides them:

1. Publish a tagged runtime and AssetWorks release after the pinned preview APIs stabilize; retain the source pin until then.
2. Evaluate a persistent index or explicit state sharding for collections above the 100,000-directory-entry ceiling, with migration and rebuild tests.
3. Add container or OS process isolation before accepting untrusted codec binaries or exposing conversion as a service. The offline protocol allowlist is not an OS sandbox.
4. Add operator backup/restore and disaster-recovery drills, including loss of the entire storage volume; process-crash recovery cannot reconstruct destroyed storage.
5. Consider public-key manifest verification and key rotation only if cross-organization authenticity becomes a requirement. Current HMAC uses a shared secret and does not provide non-repudiation.
6. Expand the intentionally narrow media format/operation matrix using licensed fixtures, output validation and platform conformance for each addition.
