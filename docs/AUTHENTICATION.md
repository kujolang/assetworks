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
