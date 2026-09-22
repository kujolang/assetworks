# A complete local media evidence workflow

From the repository root, choose a new output directory:

```bash
kujo run examples/walkthrough.kujo -- /absolute/path/to/new-demo
```

The Kujo program plans the work, binds the original SVG to a manifest, records the accompanying caption and transcript files, reconciles all four records against their creation events, and exports them to `new-demo/export.json`. It prints a JSON result for every command and exits unsuccessfully if any step fails. Generated input payloads and state are kept in the chosen directory for inspection.

The original samples in [media/](media/) are CC0. The captions describe a hypothetical five-second still-image presentation; they are supplied text, not generated speech recognition. The SVG contains its own accessible title and description.

Read [walkthrough.kujo](walkthrough.kujo) to see the full Kujo orchestration. Follow calls into [core](../src/core.kujo), [domain rules](../src/domain.kujo), [audit reconciliation](../src/audit.kujo), and [storage/recovery](../src/storage.kujo). Re-running against an existing output directory fails intentionally; choose a fresh directory rather than rewriting immutable records.
