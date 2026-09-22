# Security and authority

AssetWorks records local media evidence. It does not execute publishing actions or enforce hosted identity, role-based permissions, or tenant isolation. Keep state and artifact directories under a trusted operator's control.

Record IDs reject traversal. State and export paths reject existing symlinked components; provide canonical paths (for example `/private/tmp` rather than `/tmp` on macOS). Record, event, journal, input, config and export file operations additionally use filesystem-root-anchored no-follow reads or writes. Attached-file hashing still needs the streaming confinement follow-up listed in the review. Input files are capped at 1 MiB, CLI artifacts at 64 MiB, and serialized records at 1 MiB. Record IDs cannot be overwritten through creation commands.

Immutable journals support process-crash recovery across individual atomic writes. Validation reconciles record bytes and creation events, detects orphans and incomplete transactions, and validates record/domain structure and attached checksums. Export refuses all active-state destinations, including with `--force`. See [recovery operations](RECOVERY.md). Secret-shaped input keys are rejected, but this is not general secret detection.

See [the current review](REVIEW_2026-09-22.md) for unresolved security and durability work. Optional HMAC helpers provide shared-key authentication, not independent public-key identity or non-repudiation.
