# AssetWorks hardening, 2026-11-25

Baseline `ea5e034`. Reviewed storage publication, immutable journal and audit reads, maintenance resumption, backup and restore receipts, authentication, and local and container adapter boundaries.

- `2573beb` applies the active-state check to record, event and transaction readers. The fixture interrupts migration after record and history bytes are copied, confirms both reports fail, resumes, and confirms reporting works again. The same commit rejects content-addressed artifact names that disagree with their digest during backup and restore. The interrupted-backup regression confirms a conflicting file remains available for inspection and no completion receipt is published. Restore processes one inventory page at a time.
- `2026468` stages codec input through the bounded native copy+digest primitive. In three paired 8 MiB copy fixtures on macOS x64, median peak RSS fell from 53,284,864 to 11,214,848 bytes. All copies had identical SHA-256, and the benchmark measured input staging and verification only.
- `be7304f` prepares sharded layout markers and metadata in a sibling directory and atomically publishes the complete state without replacing an existing target. A caller polling the public path saw incomplete layouts in 12 of 12 baseline invocations and zero of 12 after the change. Failed publication keeps the sibling staging directory for inspection.

The full local macOS gate passed on published Kujo 1.5.0 with FFmpeg and ffprobe 8.0.1. It covered 577 baseline and 584 final assertions, 32 distinct writers, a separate 32-writer same-ID race, exact-byte recovery, real codec transformations, and the installed launcher outside the source tree. The hosted workflow covers additional operating-system, large-file, and container tests.
