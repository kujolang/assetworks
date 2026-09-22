# Security and authority

AssetWorks records local media evidence. It does not execute publishing actions or enforce hosted identity, role-based permissions, or tenant isolation. Keep state and artifact directories under a trusted operator's control.

Record IDs reject traversal. State and export paths reject existing symlinked components; provide canonical paths (for example `/private/tmp` rather than `/tmp` on macOS). These checks do not protect against concurrent filesystem replacement by another local actor. Input files are capped at 1 MiB, CLI artifacts at 64 MiB, and serialized records at 1 MiB. Record IDs cannot be overwritten through creation commands.

Individual file writes are atomic, but a record and its audit event are not one crash-atomic transaction. Validation checks record/domain structure and attached artifact checksums; it does not reconcile history. Never export into managed state directories: `--force` currently allows explicit file replacement. Secret-shaped input keys are rejected, but this is not general secret detection.

See [the current review](REVIEW_2026-09-22.md) for unresolved security and durability work. Optional HMAC helpers provide shared-key authentication, not independent public-key identity or non-repudiation.
