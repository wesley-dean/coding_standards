# Decisions

## Standards Distribution Bundles

The repository distributes standards as deterministic, versioned profile archives rather than requiring consumers to declare every standard file individually.  Each language profile contains the selected language standards plus the common `general`, `markdown`, `repository`, and `adr` categories when present, together with the corresponding examples; the `all` profile contains the complete `standards/` tree.  Examples are maintained beneath `standards/examples/` so consuming repositories materialize them beneath `doc/standards/examples/`.  Bashdeps remains responsible for acquiring and verifying the archive, while the consuming repository's Make integration safely replaces `doc/standards/` with the verified archive contents.  See [ADR-001: Distribute Standards as Profile Archives](adr/ADR-001-standards-distribution-bundles.md).
