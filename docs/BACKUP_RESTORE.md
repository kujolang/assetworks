# Backup and volume-loss recovery

Stop writers before backup or restore. Directory pages do not provide a cross-file snapshot. Use operator-owned, nonsymlinked directories; the restore parent must exist and remain unchanged during publication. Backups are unencrypted: protect their parent directory and storage separately.

```sh
assetworks backup --state production-state --output backup-2026-09-22 --json
# Retain data.backup_sha256 outside the backup, through a trusted channel.
assetworks restore --state backup-2026-09-22 --output restored-state \
  --backup-sha256 THE_RETAINED_64_HEX_DIGEST --json
assetworks validate --state restored-state --artifact-root restored-state/artifacts --json
```

`--state` names the backup directory for `restore`. Neither command replaces an existing destination. Restoration verifies the externally retained completion-manifest digest, every hash-linked inventory page and every copied file. It reconciles all record, event and transaction pages before atomic no-replace publication from a private staging directory. A failed restore leaves an explicitly reported staging directory for inspection; the requested destination stays absent. Remove only owned failed staging directories after inspection.

Backup preserves exact immutable record/event/journal bytes in a sharded layout. Referenced media is copied into `artifacts/SHA256.blob`, deduplicated by digest, with a fixed 64 KiB native buffer and a 4 GiB per-artifact ceiling. Inventory pages contain at most 1,000 entries and 1 MiB. Copies materialize sparse files: reserve space for their logical size, and for both the backup and staged restored copy during recovery. Only managed evidence and referenced media are copied; arbitrary files, keys, transient adapter files and unrelated directories are excluded. The completion manifest is written last, after independent validation of the copied state and media.

Original artifact paths inside signed records remain unchanged. Use the explicit `--artifact-root` resolver to verify restored content by recorded digest without rewriting those signatures. Supply it when backing up a restored state again. An attached-file hash still has to match; the resolver does not relax size, digest, signature or audit validation.

For HMAC manifests, pass the separately retained `--key-file`. For public signatures, pass the separately trusted `--trust-store`; a private signing key is unnecessary. Current revocation policy applies during restoration. A backup digest detects changes only when its external receipt remains trusted. The backup is not self-authenticating, and loss of both the backup and its external trust/key material cannot be repaired by this tool.

The disaster-recovery tests delete the complete original state/media volume, restore into a new location, compare immutable bytes, validate restored media, and refuse changed manifests, inventory, media, links, existing destinations and revoked signers. Complete paginated validation remains required when manually checking a large restored state; a single `validate` page is not a whole-state certificate.

For the native copy component, optimized Linux [run 35783327038](https://github.com/kujolang/assetworks/actions/runs/35783327038) copied a 4 GiB sparse source into a fully materialized destination in 21,063 ms with 22,192,128-byte peak process RSS. The benchmark checks source/destination digests and rejects an insufficient bound. This measures one copy, not complete backup/restore throughput; reconciliation, signatures, inventory and repeated verification add work. Run `kujo run scripts/copy_benchmark.kujo -- 4294967296` on representative storage with enough free logical space before sizing a recovery window.
