# Optional container isolation

Local adapters run explicitly trusted codecs with host process authority. Set `isolation` to `container` for a Linux-container boundary around decoding, encoding and probing. A trusted local Docker daemon is required; Docker Desktop can provide it on macOS/Windows. There is no fallback to local execution when isolation fails.

Build the supplied image, inspect its immutable ID and put that ID into an operator-controlled configuration:

```sh
docker build -f containers/Dockerfile -t assetworks-codecs:local .
docker image inspect assetworks-codecs:local --format '{{.Id}}'
docker context inspect --format '{{json .Endpoints.docker.Host}}'
```

```json
{
  "schema_version": "1.0.0",
  "provider_class": "ffmpeg",
  "isolation": "container",
  "docker_binary": "/absolute/canonical/path/to/docker",
  "docker_host": "unix:///absolute/path/to/docker.sock",
  "image": "sha256:REPLACE_WITH_64_HEX_LOCAL_IMAGE_ID",
  "offline": true,
  "timeout_ms": 30000,
  "max_output_bytes": 65536,
  "artifact_max_bytes": 8388608
}
```

The example's placeholder image is deliberately invalid. Use a real locally built image ID. Mutable tags and remote TCP daemons are refused; runtime uses `--pull never`. Windows local named-pipe endpoints are accepted. The image must supply `/usr/bin/ffmpeg`, `/usr/bin/ffprobe`, `/usr/bin/dd`, `/usr/bin/base64` and `/bin/sleep`; codec executable paths are fixed inside the container.

Each operation runs as UID/GID 65532, with network disabled, no host or Docker-socket mounts, read-only root, all capabilities dropped, no privilege escalation, one CPU, 256 MiB memory with no swap, 64 processes and 128 open descriptors. Writable `/work` and `/tmp` are bounded noexec/nosuid/nodev tmpfs mounts of 16 MiB and 8 MiB. Large/high-resolution jobs can legitimately exceed these limits and fail.

Input uses bounded stdin; output uses bounded base64 stdout and confined no-replace host publication. No container-supplied archive is extracted on the host. Adapter input/output remains capped at 8 MiB; the encoded output transfer is separately capped at approximately 11 MiB. Codec/probe logs retain the configured limit. Each Docker operation has the configured timeout; this is not one aggregate wall-clock deadline. A fixed 300-second lifetime bounds an abandoned container's running time.

An empty private Docker CLI configuration prevents ambient registry credentials/context from being used. Success requires removal of the owned container. Process crashes or daemon loss can leave stopped containers/private configuration directories; inspect containers bearing `org.kujolang.assetworks.isolated=true` and remove only confirmed abandoned AssetWorks instances. Do not run blanket container cleanup on a shared daemon.

The daemon, container image, OS kernel and operator-owned state/restore directories remain trusted. This boundary limits codec access; it does not defend against a malicious daemon or kernel compromise, certify hostile media as safe, or make the tool a multi-tenant service. Build-time package fetching is separate from offline runtime execution. Record the resulting image ID and rebuild deliberately for codec security updates.

`tests/isolation_test.kujo` exercises a real daemon: host-sentinel access, network connect, rootfs writes, tmpfs exhaustion, oversized memory allocation, capability/user settings and real WebP conversion. CI requires these tests on Linux; the full native adapter suite remains required on Linux, macOS and Windows.
