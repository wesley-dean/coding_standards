# ADR-002: Use One Standards Archive and a Consumer Update Workflow

## Status

Accepted

## Supersedes

[ADR-001: Distribute Standards as Profile Archives](ADR-001-standards-distribution-bundles.md)

## Context

ADR-001 established deterministic release archives, committed consumer snapshots,
and a clean separation between the canonical `standards/` tree and copies
materialized beneath `doc/standards/` in consuming repositories.  Those parts of
the decision remain useful.  Experience with the first implementation showed that
two other parts created more machinery than value: language-specific release
profiles and bashdeps-driven consumer materialization.

The standards library is composed primarily of Markdown documents and small source
examples.  Shipping several standards that do not apply to a particular consuming
repository has negligible storage and transfer cost.  Avoiding those files through
language-specific profiles requires the publisher to maintain profile lists,
common-category lists, profile composition logic, multiple release artifacts,
profile-specific tests, and consumer guidance for single- and multi-language
repositories.

Applicability is also a governance question rather than a packaging question.  A
Bash repository may receive Python or PHP standards without those standards
becoming applicable.  The consuming repository's instructions, ADRs, and local
governance determine which standards govern its work.

The consumer side can likewise be simpler.  GitHub Actions runners already have
network access to GitHub releases and can perform a controlled, manually requested
update.  The materialized standards are committed to the consuming repository, so
coding agents and restricted development containers do not need network access to
obtain them during normal development.

The update also needs a small, durable provenance record.  The project-root `.env`
file is an appropriate location because the metadata describes the consuming
repository's selected standards release rather than a file inside the managed
`doc/standards/` tree.  Keeping the provenance outside that tree also allows the
workflow to replace `doc/standards/` completely without preserving special files
inside it.

## Decision

The coding-standards repository will publish one deterministic standards archive
per release.  Consuming repositories will normally update their committed
standards snapshot through a manually dispatched GitHub Actions workflow.

### Single release archive

Each release publishes exactly these standards artifacts:

```text
coding-standards.tar.gz
coding-standards.tar.gz.sha256
```

The archive contains the complete contents of `standards/`, including every
language, general and cross-cutting standards, and all examples.

The archive does not contain an outer `standards/` directory.  Its root therefore
contains entries such as:

```text
general/
awk/
bash/
php/
python/
markdown/
repository/
adr/
examples/
```

Categories that do not yet contain tracked files are naturally absent from a
particular release.

Extracting the archive beneath `doc/standards/` produces the desired consumer
layout directly:

```text
doc/standards/general/
doc/standards/bash/
doc/standards/examples/
...
```

The deterministic-generation, archive-path validation, symbolic-link rejection,
normalized metadata, checksum publication, and immutable-release requirements from
ADR-001 remain in force for this single archive.

### Standards applicability

Receiving the complete standards library does not make every standard applicable
to every consumer.

The consuming repository determines applicability through its own governing
documentation.  For example, an `AGENTS.md` file may direct developers and coding
agents to the general, Bash, Markdown, repository, and ADR standards while ignoring
language standards unrelated to that repository.

Distribution therefore answers "which version of the standards library is present?"
rather than "which subset of the library applies here?"

### Consumer update workflow

The recommended update mechanism is a GitHub Actions workflow in the consuming
repository triggered by `workflow_dispatch`.

The workflow accepts an optional `version` input.  Version selection follows this
precedence:

1. a non-empty `workflow_dispatch` `version` input;
2. `CODING_STANDARD_VERSION` from the project-root `.env`; or
3. the literal value `latest` when neither of the preceding values exists.

The workflow input intentionally has no YAML default.  The actual default is the
version already recorded by the consuming repository, if one exists.

The special value `latest` is a request to resolve the current latest GitHub
release.  It is never persisted as provenance.  Before materialization, the
workflow resolves `latest` to the release's concrete tag, such as `v1.4.0`.

An explicitly requested concrete tag is used exactly as supplied.  This permits an
intentional upgrade, downgrade, or reconstruction of a specific historical
release.  Version ordering is not inferred by the workflow.

When the resolved version differs from the currently recorded
`CODING_STANDARD_VERSION`, the workflow downloads and verifies that release,
materializes it into a fresh staging directory, replaces the managed
`doc/standards/` tree, updates project-root provenance, and proposes the resulting
repository changes for review.

A repository with no recorded version uses `latest` on its first invocation and
therefore bootstraps from the current latest release.

If the resolved version matches the recorded version, the ordinary result is a
no-op.  A future workflow may provide an explicit repair or force mode if there is
a demonstrated need to reconstruct a same-version installation; such behavior is
outside this decision.

### Project-root provenance

The consumer's project-root `.env` records the selected standards release using
the `CODING_STANDARD_` namespace:

```dotenv
CODING_STANDARD_VERSION=v1.4.0
CODING_STANDARD_HASH=sha256:0123456789abcdef...
CODING_STANDARD_URL=https://github.com/wesley-dean/coding_standards/releases/download/v1.4.0/coding-standards.tar.gz
CODING_STANDARD_DESTINATION=doc/standards
```

The fields have these meanings:

- `CODING_STANDARD_VERSION` is the concrete resolved release tag;
- `CODING_STANDARD_HASH` is the verified archive digest, including its algorithm;
- `CODING_STANDARD_URL` is the concrete release-asset URL for that exact version;
- `CODING_STANDARD_DESTINATION` is the repository-relative managed destination.

The workflow preserves unrelated `.env` entries.  It updates only keys in the
`CODING_STANDARD_` namespace that it owns.

The persisted version and URL must always identify a concrete release.  Neither
`CODING_STANDARD_VERSION=latest` nor a `/releases/latest/` URL is valid committed
provenance.

The initial workflow fixes the destination at `doc/standards` and records that
value as provenance.  Recording the destination does not imply that arbitrary
workflow-supplied filesystem destinations are supported.

### Download and verification

The workflow downloads both release assets from the fixed upstream repository:

```text
wesley-dean/coding_standards
```

The `.sha256` asset is used to verify the exact downloaded archive before
materialization.  The verified digest is then recorded in
`CODING_STANDARD_HASH` as `sha256:<hex-digest>`.

The consumer does not need bashdeps for this standards-update path.  This is a
narrow decision about standards distribution; it does not change bashdeps or its
usefulness for other dependencies.

### Fresh materialization

The archive is extracted into a fresh staging directory before the managed
standards tree is changed.  The workflow does not overlay a new archive onto an
existing `doc/standards/` directory because removed or renamed standards could
otherwise remain as stale files.

Only after successful release resolution, download, checksum verification, and
staging does the workflow replace the managed destination and update `.env`.

The resulting `doc/standards/` tree is committed to the consuming repository.
Normal developers and coding agents therefore read standards from the ordinary
repository checkout and do not require GitHub network access during startup.

### Review through pull request

The reference workflow creates a branch and pull request when the selected release
changes repository content.  The pull request contains both:

- the updated `CODING_STANDARD_` provenance in project-root `.env`; and
- the exact changes beneath `doc/standards/`.

This makes adoption of a standards release reviewable as an ordinary repository
change.  Direct commits to the default branch are not the reference workflow.

## Alternatives Considered

### Language-specific release bundles

ADR-001 selected language profiles plus an all-inclusive profile.

This was superseded because the files being excluded are small Markdown documents
and examples, while profile selection creates real publisher and consumer
complexity.  The packaging layer should not encode which standards apply to a
project.  One complete library archive is easier to build, test, publish, explain,
and adopt.

### An `all` profile alongside language profiles

Keeping the existing profiles and instructing most consumers to use only the
`all` bundle would preserve compatibility but retain unused release artifacts,
configuration arrays, tests, and documentation.  The additional surface provides
no current benefit, so future releases use only the single archive.

### Bashdeps plus Make in every consumer

ADR-001 used bashdeps for acquisition and verification and Make for extraction.

That design remains technically valid, but it requires consumer repositories to
carry dependency declarations and materialization targets for a dependency that is
updated infrequently and already lives on GitHub.  A manually dispatched GitHub
Actions workflow can perform the networked update where GitHub access is available,
while the committed materialized tree remains available in restricted development
containers.  The narrower workflow is therefore preferred for standards.

### Git submodules

A Git submodule provides a precise upstream commit pointer and avoids copying the
standards files into the parent repository's object history.

It was not selected because an ordinary parent-repository checkout does not
necessarily contain populated submodule content.  Restricted coding-agent
containers may be unable to fetch a missing submodule from GitHub, which can leave
the governing standards unavailable precisely when they are needed.  The current
coding-standards repository layout would also introduce an extra repository layer
rather than placing only the distributable `standards/` contents directly beneath
`doc/standards/`, and standards changes in a consumer are less directly visible in
the parent repository's normal file diff.

### Automatically track `latest`

Persisting `latest` in `.env` or resolving the latest release on every development
checkout would make upgrades implicit.

This was rejected.  `latest` is only a workflow request value.  Once resolved, the
consumer records a concrete release tag, digest, URL, destination, and committed
standards tree.  An upgrade occurs only when the update workflow is deliberately
run with `latest` or another version that resolves differently from the currently
recorded release.

### Store provenance inside `doc/standards/`

Keeping a version file or `.env` inside the materialized tree would make the
standards directory self-describing.

This was rejected because the provenance describes the consuming repository's
selection and because the managed standards directory should be replaceable as one
unit.  Project-root `.env` keeps configuration outside the tree it governs and can
coexist with unrelated project configuration through the `CODING_STANDARD_`
namespace.

## Consequences

### Positive

- Every release has one standards archive and one checksum.
- Adding a new language or standards category requires no packaging-profile change.
- Consumers do not need to decide between language and all-inclusive bundles.
- Applicability remains a repository-governance concern rather than a packaging
  concern.
- Consumer update logic is centralized in a manually invoked GitHub Actions
  workflow.
- The root `.env` provides compact, inspectable provenance for humans and agents.
- `latest` is convenient for intentional upgrades without weakening reproducibility.
- Committed `doc/standards/` content remains available to offline developers and
  coding agents without a network bootstrap.
- Standards adoption produces a normal pull-request diff showing the exact text
  being adopted.

### Negative

- Single-language repositories receive standards for languages they do not use.
- Consuming repositories commit derivative standards files and a small amount of
  provenance metadata.
- The reference updater depends on GitHub Actions and GitHub release availability
  when an update is requested.
- A matching recorded version is ordinarily a no-op even if local managed files
  were manually damaged; same-version repair is not part of the initial workflow.
- Projects that do not otherwise use a root `.env` gain one for standards
  provenance.

## Compatibility and Migration

Release archives produced under ADR-001 remain valid historical artifacts.  They
are not rewritten or removed from existing releases.

Future releases governed by this ADR publish only:

```text
coding-standards.tar.gz
coding-standards.tar.gz.sha256
```

A consuming repository migrating from the ADR-001 model should:

1. add the standards update workflow;
2. add or update the four `CODING_STANDARD_` values in project-root `.env`;
3. run the workflow for the desired concrete version or `latest`;
4. review the resulting `doc/standards/` replacement and provenance changes;
5. merge the generated pull request; and
6. remove obsolete standards-specific bashdeps declarations or Make targets when
   they are no longer used for another purpose.

Repositories that already commit `doc/standards/` do not need to change how coding
agents consume those files.

## Expected Outcome

A consuming repository can install or update the complete standards library by
running one manually dispatched GitHub Actions workflow.  With no explicit input,
the workflow retains the version already recorded in project-root `.env`; a new
repository defaults to the latest release.  Supplying `latest` explicitly requests
an intentional upgrade to the current latest release, while supplying a concrete
tag selects that exact release.

After a successful update, the consuming repository records the concrete version,
verified hash, concrete release URL, and `doc/standards` destination in `.env`, and
the complete materialized standards tree is available from an ordinary checkout
without any development-container network dependency.
