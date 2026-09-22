# Streaming artifact checksums

Artifact attachments default to 64 MiB. Opt in with `--max-artifact-bytes N` (1..4294967296). The manifest records its bound, byte count and SHA-256; validation uses the same bound. Legacy records without a bound retain 64 MiB. The explicit FFmpeg adapter separately limits source and generated files to 8 MiB.

Kujo's `sha256_file_beneath` opens each path component without following symlinks, requires a regular file, checks metadata and counts actual bytes through a fixed 64 KiB buffer. It refuses growth beyond the bound (one additional byte may be read to detect it). An ancestor rename cannot redirect an already opened file handle. Operators must still protect files from in-place concurrent modification; hashing a mutable file is not a snapshot or a transaction. Store artifacts immutably for repeatable verification.

Run each size in a fresh process:

```sh
kujo run scripts/streaming_benchmark.kujo -- 68157440
kujo run scripts/streaming_benchmark.kujo -- 1073741824
kujo run scripts/streaming_benchmark.kujo -- 4294967296
```

The benchmark creates a real logical sparse file with a fixed nonzero header, creates a manifest through the CLI dispatch, validates it, independently compares `sha256_file`, and reports elapsed milliseconds and process peak RSS. Every logical byte is hashed, but sparse zero-filled fixtures do not represent cold-disk throughput. No claim is made about arbitrary codec support or multi-gigabyte adapter execution.
