# Next-session implementation — 2026-09-22

Scope: all six opportunities in REVIEW_FOLLOWUP_2026-09-22.md, requested for implementation now. This is the active acceptance checklist, not a completion claim.

1. **Tagged releases:** integrate the reviewed runtime APIs, publish a tested runtime tag and AssetWorks release, and verify installation from the published artifacts. Keep the immutable runtime source pin until the replacement release is verified.
2. **Large collections:** evaluate indexing versus explicit sharding; implement the selected layout with bounded pagination above 100,000 entries, legacy migration, rebuild/recovery tests, and measured resource receipts.
3. **Process isolation:** add an opt-in container execution boundary with no network, restricted mounts, resource limits and fail-closed configuration. Test actual attempted network/host access and resource-bound behavior; retain explicit local execution for trusted codecs.
4. **Disaster recovery:** implement bounded, verifiable backup and restore, preserve exact immutable bytes and artifacts, reject unsafe destinations/tampering, and drill complete loss of the original state volume.
5. **Public-key verification:** add externally verifiable manifest signatures and an explicit trusted-key rotation/revocation policy. Test wrong-key, tampering, downgrade, revoked-key and legacy-HMAC behavior without live credentials.
6. **Media formats:** expand the supported format matrix with original CC0 fixtures, codec/dimension/digest checks and round-trip tests on Linux, macOS and Windows.

Completion requires all six items, updated user documentation, regression gates, release evidence, committed/pushed clean trees, and a retrievable Strata handoff. Conditional wording in the earlier opportunities is resolved by this request to perform the work; none is silently deferred.

## Current evidence

- Starting application revision: `681b01b`; existing executable baseline: `f57791d`.
- Existing full application matrix: https://github.com/kujolang/assetworks/actions/runs/35771712287 (189 assertions per platform).
- Supporting runtime PR #10 is open at `8f64343`; latest published runtime is v1.4.0, and latest AssetWorks release is v0.2.0.
- Docker server is available locally for real isolation checks.

## Implementation status

All six items remain in scope. No final release or overall completion is claimed.

- Media expansion implemented in `206b52b`: JPEG, WebP and FLAC encode/decode, odd image dimensions, codec allowlists, original CC0 derivative fixtures and 33 adapter assertions. Platform CI verification remains pending.
- Public-key policy implemented in `42fbcc9`: explicit RSA trust stores, domain-separated signatures binding identity and public-key fingerprint, active/retired/revoked rotation, validity windows, downgrade refusal and 25 new assertions. Legacy HMAC checks still pass. Platform CI verification remains pending.
- The full local gate passes 235 assertions, both contention scenarios and remaining checks using the pinned-capable debug runtime. Log: `/private/tmp/assetworks-next-formats-auth-gate.log` (local evidence, not a shipped artifact).
- The instructed older sibling `kujo/target/release/kujo run tests/test.kujo` fails at doctor; it does not supply the pinned preview contract. The release/install item must resolve this runtime gap rather than claiming that binary passed.
- Tagged releases, large-state layout/migration, isolated execution and backup/restore are not yet implemented.
