# AssetWorks follow-up review, round 2 — 2026-09-22

AssetWorks is an operator-controlled local tool with explicit limits. Passing its acceptance checks does not establish universal usefulness, hosted multi-tenant safety, or suitability for every enterprise deployment. The useful claim is narrower: reproducible media/provenance workflows, immutable local evidence, explicit trust policies and tested recovery/isolation boundaries.

## Delivered scope

| Area | Implementation | Acceptance evidence |
| --- | --- | --- |
| Media | PNG, JPEG, WebP, WAV, FLAC and MP4; original CC0 fixtures; codec and round-trip checks | Full 300-assertion matrix 35785986508 passed on Linux, macOS and Windows at 150057d |
| Authenticity | RSA public trust stores; active/retired/revoked rotation; domain-separated identity binding; HMAC compatibility | Public-key suite plus signed restore/revocation checks passed in all three platform jobs of run 35785986508 |
| Large state | Explicit 256-shard collections, bounded pages, out-of-place exact-byte migration/rebuild | 46 assertions; optimized 100,001-entry migration and exact-byte traversal passed in Linux run 35783043092; [phase measurements](STORAGE_LAYOUT.md#measured-example) |
| Disaster recovery | Hash-linked bounded inventory, externally retained root receipt, streaming media copies, private staging and no-replace restore | 15 volume-loss/tamper assertions and four public-signature backup/restore assertions passed on all three platforms |
| Codec isolation | Explicit immutable local image, no network or host mounts, unprivileged execution, read-only root and resource limits | 21 real Docker checks passed locally and in Linux run 35783043092 |
| Distribution | Signed AssetWorks v0.3.0 and Kujo v1.5.0 native releases; archive digests bound into signed tags | Runtime downloaded-install run 35793560616 and application published-install run 35793920463 passed on all five native platforms |

All six implementation items are delivered. Use [the release acceptance record](NEXT_SESSION_IMPLEMENTATION.md) for exact tags, checksums and verification. Kujo’s independent npm publication remains unresolved; native GitHub downloads are verified and do not depend on that registry channel.

## Operating boundaries

- Keep state, trust stores, backup receipts and Docker configuration under operator control. The daemon/kernel and chosen image remain trusted.
- Stop writers during migration, backup and restore. Pages are not cross-file snapshots; sharding does not provide distributed locking.
- Preserve the externally retained backup digest and separate key/trust material. A backup cannot establish its own authenticity.
- Follow all three validation cursors. Doctor and individual validation pages are not whole-state certificates.
- Signed records preserve original paths; restored media verification uses explicit `--artifact-root` without rewriting signatures.
- Run local codecs only with the host authority you intend. Container mode fails closed and has deliberately fixed resource limits.

## Next-session worklist

These follow-ups extend the delivered release. The first item is an unresolved distribution issue; the others are additional capabilities and operating improvements.

1. **Restore Kujo npm publication authorization.** [Publisher run 35793388734](https://github.com/kujolang/kujo/actions/runs/35793388734) returned E404 for the existing darwin-arm64 package; public registry lookup still reports 1.4.0. A maintainer should review trusted-publisher configuration and publish permissions, then retry the already-verified packages from build 35787043614 and run the npm install matrix. The precise authorization cause is unproven. Native GitHub releases are unaffected.

2. **Resumable maintenance jobs.** Design restartable backup/migration receipts, safe cleanup of abandoned staging, and operator-visible progress without weakening immutable publication. Verify restart at every write boundary and retention of conflicting evidence.
3. **Release and codec update automation.** Add a documented cadence for rebuilding the pinned codec image, recording package/SBOM provenance and testing security updates. Evaluate snapshot package repositories for reproducible image builds; runtime image IDs already prevent silent tag drift.
4. **Trust distribution and freshness.** Evaluate signed, versioned trust-store distribution, revocation freshness, offline grace policy and trusted timestamps. Current validity times are issuer-asserted; manual trust-store updates do not prove freshness.
5. **Large-state cost and adversarial skew.** Use the recorded optimized-runtime benchmark to set practical operating guidance. Measure skewed shard distributions, multi-page audits and backup throughput; add a persistent index only if measured benefits justify crash-rebuild and consistency complexity.
6. **Broader media workflows.** Prioritize a small set of user-requested formats and actual accessibility processing adapters, each with licensed fixtures, deterministic probes, bounded execution and complete platform coverage. Do not imply universal codec support.
7. **Operational recovery exercises.** Add scheduled operator-run restore drills and optional evidence exports for monitoring systems. Include loss of a backup device, unavailable trust material and interrupted publication, with explicit retention and privacy policies.

## Evidence to preserve at release

The acceptance record preserves final commits, signed tags, native archive checksums, platform runs, installed-artifact results and measured timing/RSS scope. Strata holds the session handoff. Only the unresolved npm authorization incident warrants SignalBox review; completed work and routine verification do not.
