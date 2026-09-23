# Resumable maintenance and recovery drills

Available on development `main`; these additions are not in the existing v0.3.0 archive.

Stop writers and other maintenance processes before starting or resuming. Source, destination and parent directories must remain under the operator's control. One worker owns a job; these commands do not supply distributed locks or snapshots.

```sh
assetworks migrate --state ./state --output ./rebuilt --json
assetworks migrate --state ./state --output ./rebuilt --resume --json
assetworks backup --state ./state --output ./backup --json
assetworks backup --state ./state --output ./backup --resume --json
assetworks maintenance status --state ./backup --json
```

`--resume` requires the original job receipt and matching source/destination and artifact-root arguments. Existing files are streamed and compared to their source; differing bytes, links, missing files and unexpected state entries stop the job. Retries revisit the source rather than trusting a stored cursor. This saves copying completed large files, but still requires full verification time. Progress counts are advisory and may restart from zero. They cannot authorize completion.

Backup inventory pages are reconstructed deterministically, including unique content-addressed artifacts. A conflicting inventory or completion manifest is retained and rejected. Completion is established by `migration.json` plus removal of the incomplete marker, or `backup.json` plus its externally retained digest. A process can fail after publishing a valid completion receipt; inspect it and retry explicitly. The original error alone cannot prove that publication never happened.

Incomplete migrations are unusable as application state from the first durable job write. Finished migrations still require semantic validation before switching an application to them. Backup copies and restores independently validate all records, journals, history and referenced media.

For abandoned incomplete work, stop its worker first, then quarantine it:

```sh
assetworks maintenance abandon --state ./incomplete-backup --output ./quarantine-2026-09-23 --json
```

This atomically moves the owned job directory to a new name on the same filesystem. It never deletes evidence, overwrites a destination, or abandons an output with a completion manifest. The old job receipt intentionally prevents resuming from its new location. Review retained bytes and apply your organization's retention policy before manually removing the quarantine. No automatic recursive deletion or age-based cleanup runs against user data.

## Operator restore drill

```sh
assetworks drill --state ./backup --output ./drill-restored \
  --backup-sha256 EXTERNALLY_RETAINED_DIGEST --trust-store ./trust.json --json
```

Omit trust options only for unauthenticated data; use `--key-file` for HMAC data. The command executes complete restore validation and no-replace publication. It retains restored state for inspection. A successful JSON summary includes verified status, file/byte counts, elapsed milliseconds and backup digest, without local paths, actors, keys or media content. Redirect stdout into your existing monitoring collector if needed; a failed drill exits nonzero. Even digests may correlate private datasets, so restrict access to monitoring exports.

Run a real-data drill at least monthly and after backup-device, trust-policy or release changes, using your existing scheduler and a unique new output directory. Retain receipts separately from backup media. Rotate tested backup devices; include an exercise where the primary device and primary key location are unavailable. Retain restored copies only as long as needed under your data policy.

The weekly `operations.yml` workflow rehearses synthetic source-volume loss, unavailable/wrong trust, backup-device loss and interruption before every restore publication boundary. It retains fixture-only evidence for 30 days. It does not access production data and does not prove your organization's backups are recoverable.
