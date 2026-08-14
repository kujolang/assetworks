# Contracts

Contract 1.0.0. AssetWorks owns: Asset Source; Asset Job; Transformation Step; Media Variant; Caption Artifact; Transcript Artifact; Accessibility Record; Media Manifest; Production Receipt. Records carry schema/tool versions, stable IDs, actor, timestamp, provenance, command, and payload. Consumers accept compatible 1.x, preserve safe unknown payload metadata, and reject incompatible majors. JSON uses `ok/data/error/tool_version/contract_version`. Offline upstream fixtures identify repository, tag, schema, and checksum.
