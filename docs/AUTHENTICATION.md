# Optional manifest authentication

Use an explicitly supplied UTF-8 key file containing 16..4096 bytes:

```bash
assetworks manifest --actor producer --input manifest.json --path asset.png \
  --key-file /private/keys/media-hmac --json
assetworks validate --key-file /private/keys/media-hmac --json
```

The key is read through confined file I/O, never from an ambient environment variable. All bytes in the file, including a trailing newline, are significant. Keep it outside the state directory, restrict access with operating-system permissions, and keep it out of source control and exports.

The stored authentication object contains only `algorithm: hmac-sha256` and a signature over canonical JSON of the complete record excluding that authentication object. Verification uses the runtime's constant-time HMAC verifier. A signed record requires `--key-file` during validation. When a key is supplied, unsigned manifests also fail so removing authentication cannot silently downgrade verification. Unsigned plans and other record types remain valid.

HMAC is shared-key authentication, not a public-key signature or independent proof of authorship. Every key holder can authenticate new content. Key distribution, rotation and revocation remain operator responsibilities. No key material or key-file path is persisted in a record, event or journal.

## Public-key manifests and rotation

Use RSA 2048-bit or 4096-bit PEM keys when recipients must verify without sharing the signing secret. The runtime signs SHA-256 with RSA PKCS#1 v1.5. Verification uses only an explicitly supplied operator-owned trust store; manifests cannot supply their own trusted keys.

```json
{
  "schema_version": "1.0.0",
  "keys": [
    {
      "id": "publisher-2026",
      "public_key": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----\n",
      "status": "active",
      "not_before": "2026-01-01T00:00:00Z",
      "not_after": "2027-01-01T00:00:00Z"
    }
  ]
}
```

Replace the abbreviated PEM with the actual public key. Keep the private PEM outside state, backups and source control with restrictive OS permissions. Trust stores are bounded to 256 KiB and 32 distinct identities; key files are bounded to 8 KiB.

```bash
assetworks manifest --actor producer --input manifest.json --path asset.png \
  --signing-key /private/keys/publisher.pem --key-id publisher-2026 \
  --trust-store /trusted/publishers.json --json
assetworks validate --trust-store /trusted/publishers.json --json
```

Signatures bind the complete canonical record, key identity, public-key fingerprint and an AssetWorks-specific domain separator. Signing verifies that the private key matches the selected trusted public key before writing state. The stored authentication contains the algorithm, key identity, SHA-256 fingerprint of public SPKI DER and base64 signature; no PEM or private-key path is saved.

For rotation, add a new `active` identity and change the old identity to `retired`. Retired identities verify existing signatures but cannot create new signatures through AssetWorks. `revoked` rejects all signatures for that identity, including historical ones. The record timestamp must fall in the half-open interval `[not_before, not_after)`; policy endpoints are whole UTC seconds, and fractional record timestamps are handled at those boundaries. The signed timestamp is issuer-asserted, not an independent timestamp-authority attestation. Revoke compromised keys rather than relying on a date cutoff to defeat backdating.

Distribute trust-store changes through an authenticated operator channel; the trust file is an authority input, not an automatically discovered record. Public verification rejects unsigned and HMAC manifests. HMAC remains available explicitly with `--key-file`; combining public-key and HMAC options is rejected rather than weakening either policy. Use `--id` when validating records under different authority policies in one state directory.
