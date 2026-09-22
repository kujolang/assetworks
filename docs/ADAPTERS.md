# Explicit offline media adapters

The optional FFmpeg adapter executes `render`, `convert`, `resize` and `thumbnail`. Without `--adapter-config`, those commands retain their original planning behavior and record `execution: planned`. Only successful execution and output probing produce `execution: completed`.

Create an operator-owned configuration with absolute, resolved paths to FFmpeg and FFprobe (not symlinks):

```json
{
  "schema_version": "1.0.0",
  "provider_class": "ffmpeg",
  "binary": "/absolute/resolved/path/to/ffmpeg",
  "probe_binary": "/absolute/resolved/path/to/ffprobe",
  "offline": true,
  "timeout_ms": 30000,
  "max_output_bytes": 65536,
  "artifact_max_bytes": 8388608
}
```

The input JSON describes a bounded operation, not arbitrary command arguments:

```json
{
  "schema_version": "1.0.0",
  "source_id": "source-blue",
  "operation": "resize",
  "adapter": "ffmpeg",
  "input_format": "png",
  "output_format": "png",
  "width": 16,
  "height": 12
}
```

```bash
assetworks resize --state /absolute/state --actor editor \
  --input resize.json --path fixtures/media/input.png \
  --adapter-config adapter.json --id transform-blue --json
```

Inputs support PNG, JPEG, WAV and MP4; outputs support PNG, PCM WAV and MPEG-4 video with optional AAC audio. Resize/thumbnail outputs are PNG with explicit dimensions in 1..8192. The configured binaries must include the requested codecs. Inputs and generated outputs are capped at 8 MiB; manifest-only streaming support is a separate capability. Logs are capped at 1 MiB per stream and timeout at five minutes. Each process runs without a shell or inherited credentials and permits only `file,pipe` FFmpeg protocols.

The input is copied through a confined read before execution. FFprobe must report valid streams, and resize dimensions must match. Generated files are published without replacement under `state/artifacts/SHA256.format`; the immutable record includes the generated checksum, source checksum and probe receipt. `--output` remains an export flag, not an adapter destination override. `--dry-run` validates configuration and intent without running a binary or creating state.

The operator explicitly trusts the configured binaries. This protocol policy is not an OS sandbox for arbitrary executables. A killed adapter may leave a staging directory or an unreferenced content-addressed artifact; neither is a completed record, and neither should be manually removed while a worker is active. Record/event interruption uses the journal recovery procedure.

Run real conformance tests with:

```bash
FFMPEG_BIN=/absolute/ffmpeg FFPROBE_BIN=/absolute/ffprobe \
  ASSETWORKS_REQUIRE_ADAPTER_TESTS=1 KUJO_BIN=/absolute/kujo bash scripts/validate.sh
```

The suite covers real image resizing, audio conversion, video output, dimension/digest verification, offline declarations, timeout failures, duplicate IDs and side-effect-free previews.
