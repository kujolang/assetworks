# Storage and process-crash recovery

New writes first publish an immutable `transactions/ID.json` journal with exact record and event bytes. Atomic no-replace publication elects one writer for an ID. The writer then publishes the record and creation event without replacing either file. A journal stays after completion as recovery evidence. Existing 0.1.0/0.2.0 records and their matching events remain valid without journals.

After interruption, inspect the state:

```bash
assetworks doctor --state /absolute/canonical/state --json
assetworks recover --state /absolute/canonical/state --id plan-example --json
assetworks validate --state /absolute/canonical/state --json
```

`recover` verifies the journal schema, identity, record checksum and event bytes before writing. It fills missing files, accepts already-identical files, and refuses divergent files. Repeating recovery is safe; it never deletes or overwrites evidence. A malformed journal requires operator investigation and restoration from a trusted backup, not `--force`. Doctor and whole-state validation detect incomplete or divergent journals.

New writers create no per-record lock directories. A leftover legacy `locks/ID.lock` blocks new creation for compatibility with old writers. Before removing such an empty directory, stop every legacy writer and verify that none remains active. Recover the ID if it has a new-format journal; otherwise reconcile or restore legacy evidence from backup. Do not remove locks while an old process may still own them.

Individual publication uses Kujo's confined atomic file API with filesystem-root anchors and no-follow path traversal. Journal replay handles process termination at each publication boundary; it is not a claim of transactional recovery from arbitrary disk corruption or hardware power loss. State directories remain operator-controlled, and checksums are integrity evidence rather than authentication against an operator able to rewrite every file.

The automated recovery suite kills real worker processes after journal, record and event publication, then checks reconciliation, idempotence and non-overwrite behavior. Contention testing covers both 32 distinct IDs and 32 writers competing for one ID.
