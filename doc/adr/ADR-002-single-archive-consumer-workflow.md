# ADR-002: Use One Standards Archive and a Consumer Update Workflow

## Status

Superseded by [ADR-003: Release Artifacts and Agent-Mediated Standards Adoption](ADR-003-release-artifacts-and-agent-mediated-adoption.md).

## Supersedes

[ADR-001: Distribute Standards as Profile Archives](ADR-001-profile-archive-distribution.md)

## Context

ADR-001 established deterministic release archives, committed consumer snapshots,
and a clean separation between the canonical `standards/` tree and copies
materialized beneath `doc/standards/` in consuming repositories.  Those properties
remained useful, but the language-specific packaging model created unnecessary
publisher and consumer complexity.

The standards library is primarily Markdown and small source examples.  Shipping a
few standards that do not apply to a given repository has negligible storage and
transfer cost.  Applicability is also a governance question rather than a
packaging question: receiving Python standards does not make them applicable to a
Bash-only repository.

The consumer side also needed a reproducible way to request upgrades while keeping
the materialized standards committed so coding agents and restricted development
containers would not depend on network access during normal work.

## Decision

The repository would publish one complete deterministic standards archive per
release.  The archive would contain the complete contents of `standards/` without
an outer `standards/` directory.

A consuming repository would use a manually dispatched GitHub Actions workflow to
select a concrete version or resolve `latest`, verify the release archive,
replace `doc/standards/` from a fresh extraction, record provenance, and propose
the resulting change through a pull request.

The workflow design intentionally treated `latest` as a request value rather than
persisted state.  Once resolved, the consuming repository recorded a concrete
release tag so its governing version remained reproducible.

The managed `doc/standards/` tree was to be replaced rather than overlaid so files
removed upstream could not remain as stale local content.

## Supersession

The experiment showed that installing an updater into every consuming repository
still created more machinery than value.  The durable consumer state is the
committed standards tree, provenance, and repository governance.  A maintainer or
coding agent can perform the update externally and propose the same reviewable PR
without carrying a permanent downloader, workflow, Make target, or standards
manifest in every consumer.

ADR-003 therefore retains the single complete release archive and committed
consumer snapshot while replacing the consumer-installed updater with an
agent- or maintainer-mediated adoption protocol.  It also defines the current
release artifact names, `.codingstandardrc`, and the requirement that applicable
standards be treated as governance rather than suggestions.
