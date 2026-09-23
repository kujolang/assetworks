# Offline caption conversion and transcript extraction

Available on development `main`; these additions are not in the existing v0.3.0 archive.

The built-in `kujo-captions` adapter converts a deliberately small plain-text SRT/WebVTT subset and extracts text transcripts. It runs entirely in Kujo, with no codec process, model, network call or downloaded media.

```json
{"schema_version":"1.0.0","provider_class":"kujo-captions","offline":true}
```

Save that configuration, or use `fixtures/caption-adapter.json`. A captions payload is:

```json
{"asset_id":"asset-example","language":"en","input_format":"srt","format":"vtt"}
```

```sh
assetworks captions --input captions.json --path source.srt \
  --adapter-config fixtures/caption-adapter.json --actor editor --json
```

Use `transcript` with `input_format: "srt"` or `"vtt"` and `format: "text"` to extract cue text. This is conversion of supplied captions, not speech recognition. Review timing, language, speaker labels and descriptive content for accessibility quality.

Inputs and outputs are limited to 1 MiB, with 1–10,000 cues and at most 32 KiB text per cue. Timestamps use `HH:MM:SS.mmm` (commas in SRT), with ordered non-overlapping ranges and strictly positive duration. SRT numbers start at 1 and advance consecutively. VTT starts with `WEBVTT` and a blank line. Unicode text and CRLF input are supported. Cue identifiers, settings, markup/entities, styling, regions, notes and overlapping cues are rejected explicitly. This is not a complete [WebVTT implementation](https://www.w3.org/TR/webvtt1/).

Dry runs parse and validate without writing. Execution creates a content-addressed artifact and an immutable record with source/output digest, formats and cue count. Exact round trips, malformed input, bounds, Unicode and record/audit validation run on the normal platform matrix. The original fixture in `fixtures/media/captions.srt` is CC0-1.0.
