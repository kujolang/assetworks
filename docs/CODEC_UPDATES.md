# Codec update rehearsal and provenance

`operations.yml` rebuilds the pinned-base codec image every Monday and on manual dispatch. The build refreshes Ubuntu package indexes, upgrades installed base packages and installs current FFmpeg dependencies, executes the actual isolation suite and rehearses recovery. It never pushes an image or changes a user's configured immutable image ID. Review the run and adopt a newly tested ID explicitly.

The Kujo `scripts/codec_provenance.kujo` script records the immutable image ID, platform, Dockerfile digest and installed package inventory, including an SPDX 2.3 document with package names and versions. License/download fields use `NOASSERTION`; this is package provenance, not license clearance, a complete file-level SBOM or a vulnerability scan. The collection container has no network, host mounts or elevated privileges. CI retains fixture-only receipts for 30 days. Export release evidence into your longer-lived release archive when promoting an image.

Review codec/security advisories weekly and after urgent upstream notices. Rebuild and rerun isolation/media/recovery tests before adopting updates; retain the previous immutable image and its evidence for rollback. A green conversion test does not prove absence of CVEs. Base-image digest changes require a reviewed source change as well as package-update verification.

## Reproducible package snapshots

Ubuntu's [snapshot service](https://ubuntu.com/server/docs/how-to/software/snapshot-service/) supports selecting repository state by snapshot ID. Pinning both the base digest and package snapshot would improve rebuild reproducibility, but would also freeze security updates until the snapshot is advanced. The current workflow deliberately tests current package updates; byte-identical rebuilds are not claimed. Before a release adopts snapshots, choose and record a supported snapshot for every configured repository, verify architecture availability and retained packages, then test the new image on the same gates. Do not disable repository signature verification to force an old snapshot to install.
