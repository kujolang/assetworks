# Trust distribution and freshness evaluation — 2026-09-23

Decision: preserve explicit operator-managed trust stores in this release. A signed JSON wrapper alone would not establish freshness. Do not add automatic downloading or grace-period acceptance until an operator has supplied a root-pinning, clock and rollback-storage policy. This completes the requested evaluation; authenticated distribution and trusted timestamp verification are not implemented or claimed.

| Concern | Required design before implementation | Current operating rule |
| --- | --- | --- |
| Distribution authenticity | Pin a separate policy-authority key outside downloaded bundles; bind project, bundle version, key list, issuance and expiration into a domain-separated signature | Transfer trust files through an authenticated operator channel; keep manifest keys separate |
| Rotation | Versioned authority roots, explicit old/new authorization, bounded key counts and recovery for lost roots | Review active/retired/revoked changes manually |
| Rollback | Persist the highest accepted version and digest outside restorable application state; reject older versions and same-version equivocation | Restoring AssetWorks state must not restore an obsolete trust policy |
| Freeze/revocation freshness | Compare signed expiry to a trusted clock and retain the last accepted policy; distinguish signature validity from policy freshness | Offline verification does not prove that no newer revocation exists |
| Offline grace | Explicit deployment-specific duration and receipt indicating stale-policy use; never re-enable a revoked key | No implicit grace period or freshness claim |
| Historical time | Validate a separate timestamp authority, message imprint, certificate policy and validation evidence | Record creation times remain issuer-asserted |

The [TUF specification](https://theupdateframework.github.io/specification/v1.0.27/) uses persisted metadata versions and expiration checks against rollback/freeze attacks. A suitable AssetWorks integration should reuse a reviewed distribution system rather than partially recreate it in the manifest verifier. A local version counter in the same backup would be insufficient after volume rollback. That is an architectural inference from the stated threat model.

[RFC 3161](https://www.rfc-editor.org/info/rfc3161/) specifies a separate timestamp protocol. Adopting it would require an approved authority, certificate-validation implementation and a policy for retaining verification evidence. A signed `created_at` field is not an equivalent proof.

Acceptance for a future implementation: wrong root, altered bundle, cross-project substitution, same-version different digest, lower version, expired metadata, clock rollback, restored old state, revoked keys during grace, root rotation, unavailable authority and malformed timestamp tokens must fail according to a documented policy. All core processing should remain offline when an authenticated bundle is supplied locally.
