# ADR-001: Distribute Standards as Profile Archives

## Status

Accepted

## Context

The first reusable distribution design needed to replace a per-file dependency
model in which every consuming repository had to know the complete inventory of
shared standards.  That approach coupled consumers to individual files and made
standards adoption unnecessarily tedious.

The repository also needed a way to keep standards available to coding agents and
offline developers after adoption.  A consumer checkout therefore needed to carry
a materialized copy of the governing standards rather than depend on a network
fetch during every development session.

## Decision

The original decision selected deterministic release archives organized as
language-oriented profiles plus an all-inclusive profile.  A consumer could select
the profile appropriate to its maintained languages, verify the released archive,
materialize it beneath `doc/standards/`, and commit the resulting files.

Illustrative examples were moved under `standards/examples/` so they travelled with
the standards they demonstrated and materialized beneath
`doc/standards/examples/` in consuming repositories.

The decision also preserved a boundary between byte acquisition and archive
interpretation.  Bashdeps could acquire and verify exact external bytes, while a
consumer-owned build step could interpret the archive and replace the managed
standards directory.

## Supersession

Experience showed that language-specific packaging added complexity without
meaningful value.  The standards library is small, and receiving standards for an
unused language does not make those standards applicable to a repository.
Applicability is a governance question for the consumer rather than a packaging
question.

ADR-002 therefore superseded this decision by replacing profile-specific archives
with one complete release archive and moving consumer updates away from
Bashdeps-driven materialization.  This ADR remains an accepted historical decision;
its supersession changes what currently governs without changing the fact that the
decision was accepted when made.  The repository's current distribution and
adoption contract is governed by the latest accepted ADR in this series.
