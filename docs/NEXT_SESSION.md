# AssetWorks next-session worklist

- [x] Define an adapter conformance suite for FFmpeg and image-processing providers.
- [x] Add streaming checksum support after benchmarking files above the current 64 MiB bound.
- [x] Add deterministic media-probe fixtures for duration, dimensions, and codecs.
- [x] Add signed manifests without making signing keys a baseline dependency.
- [x] Run multi-process contention benchmarks on Linux, macOS, and Windows.

Completed 2026-08-14. Local hardening and the macOS contention run are covered by `scripts/validate.sh`; the pinned CI contention matrix runs the same benchmark on Linux, macOS, and Windows.
