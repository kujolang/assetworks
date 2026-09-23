# Deployment acceptance and remaining scope — 2026-09-23

The next-session review found four remaining workstreams in [the implementation record](NEXT_WORK_2026-09-23.md). They require account access or deployment choices. No new code defect was established by this follow-up; the list is not a count of all possible future improvements.

## Release accounting

The latest published AssetWorks release is [v0.3.0](https://github.com/kujolang/assetworks/releases/tag/v0.3.0), published September 22, 2026, at `1cef9b0a832bae17b8aca165e1008c2802335b69`. At the start of this follow-up, `fc83388` was eight commits ahead of that tag. This documentation commit makes nine. This counts all commits reachable from main and absent from the release, including documentation; it does not count nine separate features or imply that these changes have shipped.

Recheck rather than carrying that number into future sessions:

```sh
gh release view --json tagName,publishedAt,url
git rev-list --count v0.3.0..HEAD
git log --oneline v0.3.0..HEAD
```

## Acceptance worksheet

Record deployment-specific values in an operator-controlled copy. Do not put credentials, production paths, private dataset names or trust material into this public repository.

| Workstream | Needed input | Completion evidence | Current status |
| --- | --- | --- | --- |
| npm distribution | Maintainer verifies trusted publisher for all six runtime packages: repository `kujolang/kujo`, workflow `publish-npm-runtime.yml`, environment `npm` | Successful publisher run; registry versions and installed-package matrix for every supported target | Blocked on account configuration review. Public resolver and darwin-arm64 still report 1.4.0; failed run 35793388734 remains the incident receipt. Exact cause is unproven. |
| Production recovery acceptance | Selected source/artifact roots, separate backup device, fresh restore destination, protected digest and trust/key locations, writer shutdown method, maintenance window, retention, recovery time/data-loss objectives | Complete backup and independent drill on selected storage; verified records/media; measured duration and size; recovery within chosen objectives; operator inspection and documented retention | Awaiting deployment inputs. Existing synthetic fixtures do not close this item. |
| Trust distribution | Decide whether manual authenticated transfer suffices; if automation is required, identify root authority, rollback-resistant storage, trusted clock, expiry/grace and root-rotation policy | Manual operating policy accepted, or implementation passes the cases in the trust review after policy is supplied | Optional extension. Current operator-managed trust is supported; automatic freshness/timestamps are not implemented. |
| Codec adoption | Target platform/daemon, chosen immutable candidate image, promotion owner, rollback image and any required scanner/license acceptance policy | Candidate's own isolation/media/recovery and provenance receipts reviewed and retained; deployment configured to that exact image; rollback reference retained | Rehearsal exists; production promotion is deployment-owned. CI's temporary runner-local image ID alone is not a transferable image artifact. |

Use the exact commands and failure-handling rules in [maintenance](MAINTENANCE.md), [trust distribution](TRUST_DISTRIBUTION_REVIEW.md) and [codec updates](CODEC_UPDATES.md). Stop writers before backup and resume; keep backup digests and current trust outside the backup failure domain. Use a fresh restore destination and retain drill output for inspection. Do not delete or rename a real production volume to imitate the synthetic volume-loss test.

## What is left

There is one unresolved distribution incident (npm), two deployment acceptance workstreams (real-data recovery and codec adoption), and one conditional feature decision (automatic trust distribution). There is no supported percentage-complete estimate or fixed number of coding sessions: the optional trust integration is not scoped until policy is chosen, and production duration depends on actual data and storage.

Preparing a new AssetWorks release is a separate distribution decision. The implementation remains on main and the v0.3.0 archive is unchanged. A release should preserve the verified source, run the release/install gates, and publish its own evidence; this document does not certify or publish it.

## Verification boundary

The latest executable source is `94b5fe3`; the [Linux/macOS/Windows matrix](https://github.com/kujolang/assetworks/actions/runs/35912889859) passed. This follow-up changes documentation only and rechecks the full local gate with Kujo 1.5.0 and explicit FFmpeg/FFprobe. Final results are recorded in the session handoff. No live dataset, registry authorization or production codec configuration was changed.
