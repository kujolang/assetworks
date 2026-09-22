# Next-session implementation — 2026-09-22

Scope: all six opportunities in REVIEW_FOLLOWUP_2026-09-22.md, requested for implementation now. This record preserves implementation and verified release acceptance.

1. **Tagged releases:** integrate the reviewed runtime APIs, publish a tested runtime tag and AssetWorks release, and verify installation from the published artifacts. Keep the immutable runtime source pin until the replacement release is verified.
2. **Large collections:** evaluate indexing versus explicit sharding; implement the selected layout with bounded pagination above 100,000 entries, legacy migration, rebuild/recovery tests, and measured resource receipts.
3. **Process isolation:** add an opt-in container execution boundary with no network, restricted mounts, resource limits and fail-closed configuration. Test actual attempted network/host access and resource-bound behavior; retain explicit local execution for trusted codecs.
4. **Disaster recovery:** implement bounded, verifiable backup and restore, preserve exact immutable bytes and artifacts, reject unsafe destinations/tampering, and drill complete loss of the original state volume.
5. **Public-key verification:** add externally verifiable manifest signatures and an explicit trusted-key rotation/revocation policy. Test wrong-key, tampering, downgrade, revoked-key and legacy-HMAC behavior without live credentials.
6. **Media formats:** expand the supported format matrix with original CC0 fixtures, codec/dimension/digest checks and round-trip tests on Linux, macOS and Windows.

Completion requires all six items, updated user documentation, regression gates, release evidence, committed/pushed clean trees, and a retrievable Strata handoff. Conditional wording in the earlier opportunities is resolved by this request to perform the work; none is silently deferred.

## Verified implementation evidence

The prior 189-assertion baseline passed in [run 35771712287](https://github.com/kujolang/assetworks/actions/runs/35771712287). The expanded format/signature suite passed 235 assertions on Linux, macOS and Windows in [run 35776897250](https://github.com/kujolang/assetworks/actions/runs/35776897250).

- **Media and authenticity:** PNG/JPEG/WebP, WAV/FLAC and MP4 fixtures, codec/dimension/round-trip checks, explicit RSA public trust stores, active/retired/revoked keys, downgrade refusal and legacy HMAC compatibility. Public-only signed restore and revoked-key refusal are covered.
- **Large state:** 46 focused assertions cover layout, cursors, exact-byte migration/rebuild and malformed/mixed state. Three optimized Linux runs verified all 100,001 entries. Migration took 54.9, 492.5 and 600.3 seconds, with about 26 MB peak RSS; full traversal/byte verification used about 175 MB. See [measured scope and variability](STORAGE_LAYOUT.md#measured-example).
- **Disaster recovery:** 15 volume-loss/tamper assertions plus four signed backup/restore cases. The original volume is deleted before restoring and validating exact immutable bytes and media. [The 4 GiB streaming-copy component](BACKUP_RESTORE.md) passed exact-byte and bound checks with about 22 MB peak RSS.
- **Container isolation:** 21 actual Docker checks passed locally and in hosted Linux runs, including attempted host/network access, resource bounds, unavailable-image refusal, real media output, receipt validation and cleanup. No local fallback is permitted for a failed container request.
- **Regression gate:** all 300 application assertions, both 32-worker contention scenarios and the external-working-directory launcher smoke passed locally at `576fafc`. The final Linux/macOS/Windows matrix passed in [run 35785986508](https://github.com/kujolang/assetworks/actions/runs/35785986508) at `150057d`, including the Windows executable-path correction. Linux also passed the benchmark phases and 21 container checks.
- **Runtime:** merged upstream `78d8725` into source `a0d433e`; 21 rooted-filesystem unit tests, five VM/interpreter boundary tests and upstream bounded stdin/digest integrations pass locally. Hosted release verification caught and corrected generated inventory drift and a duplicate documentation row. The related documentation contract suites pass together after `cb9eefa`, including both API inventories.

## Release acceptance

All six implementation items are complete through the canonical native GitHub distribution.

- **Application:** signed [v0.3.0](https://github.com/kujolang/assetworks/releases/tag/v0.3.0), source `1cef9b0a832bae17b8aca165e1008c2802335b69`. Full 300-assertion Linux/macOS/Windows matrix: [35791495202](https://github.com/kujolang/assetworks/actions/runs/35791495202), including contention, media and launcher checks. Linux adds 21 real container assertions and the 4 GiB / 100,001-entry receipts.
- **Runtime:** signed [v1.5.0](https://github.com/kujolang/kujo/releases/tag/v1.5.0), source `cc2d7dbb59a8dc05f00d629e100932f56f4062f6`; integrated by PR #10 / `44aaf58` with an identical tree. Complete gate, hardened RAG integration, five native builds and npm packaging: [35787043614](https://github.com/kujolang/kujo/actions/runs/35787043614). Public stable documentation was synchronized in `3dc9d68` and `9ec04ff` after verification.
- **Published downloads:** [runtime checks 35793560616](https://github.com/kujolang/kujo/actions/runs/35793560616) and [application checks 35793920463](https://github.com/kujolang/assetworks/actions/runs/35793920463) passed on Linux x64/ARM64, macOS x64/ARM64 and Windows x64. The packaged launcher ignores poisoned caller imports/lockfiles, preserves caller-relative state, creates records and validates audit evidence. The runtime's first macOS ARM64 upgrade check hit GitHub's public API rate limit after successful execution; the unchanged failed-job retry passed.
- **Provenance:** both signed tags are verified by GitHub and contain the archive SHA-256 digests below. Each native npm package's binary digest, version, target and full source revision matched its native archive before publication. The duplicate tag-triggered runtime build was cancelled; the already-verified exact-revision archives were published without rebuilding or replacing the signed bytes.
- **CI source pin:** `a0d433e9aba27208a59927519c529d10f1f87f06` has identical `src`, `modules`, `vendor`, Cargo metadata/lock and build-script content to the published runtime revision; later changes were documentation and installer preparation. The published-artifact matrices independently exercise shipped binaries.
- **Public bootstrap:** canonical installer and site contract updated in kujolang.ai `8d60dd0`; [production build and deployment 35793787319](https://github.com/kujolang/kujolang.ai/actions/runs/35793787319) passed. The plain public `https://kujolang.ai/install.sh` response matched the canonical installer byte-for-byte. With the version override unset, a fresh disposable-prefix installation selected Kujo 1.5.0 and passed the AssetWorks 0.3.0 installed smoke: poisoned caller imports ignored, caller working directory preserved, plan and audit validated. Final local full validation also passed using the downloaded native 1.5.0 archive.

| Published archive | SHA-256 |
| --- | --- |
| assetworks-v0.3.0.tar.gz | `fe867eff36913488895ad110705b523849ab232a3c26d89ed959e5617c17c2af` |
| kujo-v1.5.0-linux-arm64.tar.gz | `7aa3163bfc35745b18cd9bfb35d63be90e60e2fca9c2fcd48e258d3c4edcf126` |
| kujo-v1.5.0-linux-x64.tar.gz | `cd267f39c1243f6500889fb3678a1a5206ad1ef99c53d7336265ff31267f0675` |
| kujo-v1.5.0-macos-arm64.tar.gz | `2dcbda6f3e3cb01cffa1c4824571a6df316165ae3b554e1ec4a15941432f2af0` |
| kujo-v1.5.0-macos-x64.tar.gz | `1aebcd482125031104b2df79abae6db57973f1874ceb196f95989b14e287d820` |
| kujo-v1.5.0-windows-x64.zip | `a96f6ed80fb4e0b116053e2f9dbb8539dfeacf847c46a9e2496f66bdd2b4d1f4` |

## Independent registry follow-up

[Kujo npm publisher run 35793388734](https://github.com/kujolang/kujo/actions/runs/35793388734) failed with registry E404 on an existing package. Public lookup still reports 1.4.0. npm 1.5.0 publication is not claimed, and no Cargo registry publication was attempted. This requires maintainer review of publishing authorization; the exact missing permission or trusted-publisher setting is unproven. Native GitHub releases and their installed-artifact verification are complete independently.

The older sibling runtime lacks the required AssetWorks APIs and is not a supported verification substitute. Use the explicit runtime documented in README. Original unrelated checkout work was preserved.

[Round-two review and next-session worklist](REVIEW_FOLLOWUP_2026-09-22_ROUND_2.md) records the registry follow-up and further opportunities. Archived copies of this checklist reflect their source revision; the linked main-branch record contains post-publication receipts.
