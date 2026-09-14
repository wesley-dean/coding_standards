# Decisions

## Release Artifacts and Standards Adoption

The repository publishes one complete standards release archive and one SHA-256 checksum for each version.  `make all` is the canonical build interface and creates `dist/coding_standards.tar.gz` plus `dist/coding_standards.tar.gz.sha256`; generated files beneath `dist/` are ignored and are not committed.  Consuming repositories adopt or refresh a concrete released version by replacing their managed `doc/standards/` tree, recording provenance in `.codingstandardrc`, updating repository-facing governance so applicable standards are mandatory, and proposing the complete change through a pull request.  Consumers do not need permanent standards-fetching machinery such as updater workflows, Bashdeps manifests, or Make synchronization targets.  See [ADR-003: Release Artifacts and Agent-Mediated Standards Adoption](adr/ADR-003-release-artifacts-and-agent-mediated-adoption.md).

## Superseded Distribution Decisions

ADR-001 originally selected language-oriented profile archives so consumers could adopt subsets of the standards library.  ADR-002 simplified publication to one complete standards archive but still placed a dedicated update workflow in each consuming repository.  Both decisions are retained as superseded architectural history; ADR-003 is the current governing decision for release artifacts and consumer adoption.
