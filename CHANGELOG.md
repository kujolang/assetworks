# Changelog

## 0.2.0 - 2026-08-14

- Preserved validation compatibility with immutable 0.1.0 records while emitting 0.2.0 records.
- Prevented audit-history conflicts from leaving partial records and added clean-retry regression coverage.
- Tightened timestamp, actor, secret-shape, state metadata, managed-directory, pagination, record-size, and artifact-size validation while eliminating duplicate record reads.
- Hardened immutable storage, domain validation, artifact drift checks, security limits, CI, and operational documentation.
- Made unavailable media transforms fail explicitly unless an adapter is named.

## 0.1.0 - 2026-08-14

- Initial Kujo-native release with working local records, validation, contracts, fixtures, and safety boundaries.
