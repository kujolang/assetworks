# Next-session implementation — 2026-09-22

Scope: all six opportunities in REVIEW_FOLLOWUP_2026-09-22.md, requested for implementation now. This is the active acceptance checklist, not a completion claim.

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
- **Large state:** 46 focused assertions cover layout, cursors, exact-byte migration/rebuild and malformed/mixed state. Two optimized Linux runs verified all 100,001 entries. Migration took 54.9 seconds and 492.5 seconds, with about 26 MB peak RSS; full traversal/byte verification used about 175 MB. See [measured scope and variability](STORAGE_LAYOUT.md#measured-example).
- **Disaster recovery:** 15 volume-loss/tamper assertions plus four signed backup/restore cases. The original volume is deleted before restoring and validating exact immutable bytes and media. [The 4 GiB streaming-copy component](BACKUP_RESTORE.md) passed exact-byte and bound checks with about 22 MB peak RSS.
- **Container isolation:** 21 actual Docker checks passed locally and in hosted Linux runs, including attempted host/network access, resource bounds, unavailable-image refusal, real media output, receipt validation and cleanup. No local fallback is permitted for a failed container request.
- **Regression gate:** all 300 application assertions, both 32-worker contention scenarios and the external-working-directory launcher smoke passed locally at `576fafc`. The final Linux/macOS/Windows matrix passed in [run 35785986508](https://github.com/kujolang/assetworks/actions/runs/35785986508) at `150057d`, including the Windows executable-path correction. Linux also passed the benchmark phases and 21 container checks.
- **Runtime:** merged upstream `78d8725` into source `a0d433e`; 21 rooted-filesystem unit tests, five VM/interpreter boundary tests and upstream bounded stdin/digest integrations pass locally. Hosted release verification caught and corrected generated inventory drift and a duplicate documentation row. The related documentation contract suites pass together after `cb9eefa`, including both API inventories.

## Release acceptance still outstanding

Application candidate is 0.3.0, preserving 0.1.0/0.2.0 records. Runtime candidate is 1.5.0. The application CI source pin remains `a0d433e9aba27208a59927519c529d10f1f87f06`; subsequent runtime changes through `cb9eefa` are documentation only.

1. Complete the corrected runtime release gates; the final application platform matrix is green.
2. Merge the tested runtime contribution, publish checksummed Kujo 1.5.0 artifacts, and verify downloaded installations.
3. Publish AssetWorks 0.3.0 and verify its downloaded archive with the published runtime. The packaged candidate already passes launcher/module isolation, caller working-directory preservation, plan creation and audit validation; that does not substitute for checking the published download.
4. Record final tags, commits, archive checksums and installed-artifact results here, then save the retrievable Strata handoff.

The older sibling runtime lacks the required native APIs and is not a supported verification substitute. Use the explicit runtime documented in README; no unrelated checkout is modified to satisfy this requirement.

[Round-two review and next-session worklist](REVIEW_FOLLOWUP_2026-09-22_ROUND_2.md) records follow-on opportunities. They do not replace unfinished release acceptance above.
