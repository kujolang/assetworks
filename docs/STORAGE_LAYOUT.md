# Large collections and migration

`assetworks init --state PATH --layout sharded-v1` creates a new state with 256 SHA-256 filename shards in each immutable collection. Existing flat states remain supported. A marker selects the layout explicitly; mixed flat/sharded records and misplaced shard files fail closed.

A page scans one nonempty shard at a time, retaining at most 1,000 names. The existing per-page byte budgets still apply. Each shard retains the native 100,000-directory-entry ceiling. Sharding therefore raises the collection ceiling without raising per-directory memory bounds or introducing a mutable index that can become stale after a crash. Skewed or adversarial filenames can still exhaust a shard; this is not an unlimited database.

Cursors are opaque, layout-specific, and ordered by shard then record ID. Follow `next_after` until `truncated` is false; the last nonempty page can require an empty terminal page. Record, history, and transaction cursors are independent. Pages are not snapshots across concurrent writes.

## Rebuild and migration

Stop all writers, retain a backup, then run:

```sh
assetworks migrate --state old-state --output new-state --json
```

The same command migrates flat collections or rebuilds existing sharded collections. It uses a bounded filename iterator for legacy directories above 100,000 entries, copies through retained handles, and preserves exact record, history and journal bytes. No source files are modified. The destination must be new and outside the source. Failed destinations retain `.migration-in-progress` and cannot be used as state. Inspect or remove an owned failed destination before retrying into a new one.

Migration preserves evidence, including malformed JSON; it does not certify domain validity. Run complete paginated `validate` against the new state, retaining failures from every page, before switching applications to it. External artifact paths stay unchanged. Migration alone is not a backup of external media or a volume-loss recovery procedure.

`KUJO_BIN=/absolute/path/to/kujo bash scripts/sharding_benchmark.sh 100001` creates an owned synthetic legacy collection, confirms its flat scan ceiling, migrates it, traverses every shard, compares every copied file's bytes and emits timing/RSS evidence. The synthetic entries test storage, not media/domain validity; the script deletes its fixtures on success.

Preparation, migration and inspection run as separate sibling processes so peak RSS is attributable to each measured phase. Raw shard-page timings exclude domain parsing and cannot be compared directly with full `list_records` timings. Entry scan counts describe the data shards; fixed root layout checks remain part of wall time.
