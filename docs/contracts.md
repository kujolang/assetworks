# Contracts

Contract 1.0.0. AssetWorks owns: Asset Source; Asset Job; Transformation Step; Media Variant; Caption Artifact; Transcript Artifact; Accessibility Record; Media Manifest; Production Receipt. Records carry schema/tool versions, stable IDs, actor, timestamp, provenance, command, and payload. Consumers accept compatible 1.x, preserve safe unknown payload metadata, and reject incompatible majors. JSON uses `ok/data/error/tool_version/contract_version`. Offline upstream fixtures identify repository, tag, schema, and checksum.

Hardening contracts define offline FFmpeg/image-provider conformance, SHA-256 streaming checksums from 64 MiB through a configured 4 GiB ceiling, normalized duration/dimension/codec probes, optional explicit-key HMAC-SHA256 manifest signatures, and lossless 32-process contention receipts. Signing keys are never read implicitly.
