# ADR-003: Release Artifacts and Agent-Mediated Standards Adoption

## Status

Accepted

## Supersedes

[ADR-002: Use One Standards Archive and a Consumer Update Workflow](ADR-002-single-archive-consumer-workflow.md)

## Context

The repository exists to provide a canonical, versioned standards library that can
be adopted by many other repositories.  Earlier designs correctly established two
important properties: a release should represent the complete `standards/` tree as
one coherent version, and consuming repositories should commit the materialized
standards so humans and coding agents can read them without requiring network
access during normal work.

Experience with the first consumer implementation showed that installing an update
mechanism into every consuming repository created more machinery than value.  A
consumer-side GitHub Actions workflow, Bashdeps manifest, Make target, downloader,
or archive extraction script duplicates behavior that an external maintainer or
coding agent can already perform when asked to adopt or refresh the standards.
Those mechanisms also create another implementation surface that must itself be
maintained across every repository.

The durable state needed by a consumer is smaller:

1. the exact standards files it has adopted;
2. provenance identifying the released standards version and verified artifact;
3. repository governance explaining that applicable standards are requirements;
   and
4. a normal pull-request history showing each adoption or refresh.

The publishing side likewise needs one stable release contract.  Every standards
release should contain one deterministic archive of the complete contents of
`standards/` and one SHA-256 checksum file.  Local builds and release automation
should use the same Make entry point so the generated release assets do not depend
on separate CI-only build logic.

## Decision

The coding-standards repository will publish one deterministic archive and one
SHA-256 checksum for each release.  Consumers will adopt or refresh those released
standards through a normal reviewed repository change, typically performed by a
coding agent or maintainer acting on an explicit request.

No standards-fetching machinery is required in the consuming repository.

### Canonical release artifacts

`make all` is the canonical build interface for release artifacts.

A successful invocation creates exactly these build outputs beneath `dist/`:

```text
dist/coding_standards.tar.gz
dist/coding_standards.tar.gz.sha256
```

The `dist/` directory is ignored by Git.  Release artifacts are generated products
and are not committed to this repository.

`coding_standards.tar.gz` contains the complete contents of `standards/`.  The
archive does not contain an outer `standards/` directory.  Its root therefore
contains the category directories present in that release, for example:

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

The archive builder normalizes ordering, timestamps, ownership metadata,
filesystem modes, and gzip metadata.  Symbolic links beneath `standards/` are
rejected before archive creation.

The checksum file contains the SHA-256 digest of the exact archive bytes and the
archive basename:

```text
<64-hex-digest>  coding_standards.tar.gz
```

`make dist-check` remains available as a verification target.  It builds the
artifacts twice through `make all` and verifies that the resulting checksum is
identical.

### Release publication

The repository's release workflow must invoke:

```text
make all
```

before creating a GitHub Release.  The release must attach exactly the two build
artifacts:

```text
coding_standards.tar.gz
coding_standards.tar.gz.sha256
```

The release tag supplies the version identity.  Artifact filenames therefore stay
stable across releases rather than embedding the version number in the filename.

A release artifact is immutable once published.  If a build or packaging defect is
discovered after publication, source is corrected and a new release is produced.
Consumers must not depend on a silently replaced asset for an existing version.

### Version selection

A consumer adoption request may select a concrete version or the latest stable
release.

Concrete forms such as:

```text
1.4.2
v1.4.2
coding_standards@v1.4.2
```

all resolve to the concrete release tag `v1.4.2`.

The selector `latest` means the latest stable GitHub Release at the time the
operation begins.  Prereleases are not selected by `latest`.  A prerelease may be
adopted only when its concrete tag is requested explicitly.

`latest` is an input convenience only.  A consuming repository always records the
resolved concrete version.

### Consumer provenance

A consuming repository records its selected standards release in a project-root
`.codingstandardrc` file.

The file is repository configuration data, not executable shell input.  The
canonical fields are:

```toml
source = "https://github.com/wesley-dean/coding_standards.git"
version = "coding_standards@v1.4.2"
sha256 = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
destination = "doc/standards"
```

The fields have these meanings:

- `source` identifies the canonical standards repository;
- `version` identifies the concrete released version that was adopted;
- `sha256` records the verified digest of that release's
  `coding_standards.tar.gz` artifact; and
- `destination` identifies the repository-relative managed standards tree.

The recorded hash is the digest of the release archive, not a digest calculated
from a potentially modified materialized directory.

A consumer must never persist `latest` as its version.

### Managed destination

The destination recorded in `.codingstandardrc` is a managed tree.  The normal and
recommended destination is:

```text
doc/standards
```

Adoption or refresh replaces the destination from a fresh extraction of the
verified release artifact.  A new release is not overlaid onto the existing tree.
This ensures that standards removed or renamed upstream do not remain as stale
files in the consumer.

Consumer-specific documentation, exceptions, or additions must not be stored
inside the managed standards tree.  They belong in the consuming repository's own
documentation and governance.

Version equality does not imply state equality.  If `.codingstandardrc` already
records the requested version but `doc/standards/` has been modified, damaged, or
partially removed, repeating the adoption operation restores the exact released
content and proposes the resulting repair for review.

### Standards adoption protocol

When a repository is asked to "use" or "refresh" the coding standards, the actor
performing the operation must converge the repository on the selected release.
The actor may be a human maintainer, ChatGPT using the GitHub connector, another
coding agent, or equivalent trusted tooling.

The operation should:

1. identify the target repository and its default branch;
2. read existing repository governance before proposing changes;
3. resolve the requested concrete version or `latest` selector;
4. obtain `coding_standards.tar.gz` and
   `coding_standards.tar.gz.sha256` from that GitHub Release;
5. verify the archive SHA-256 digest before materialization;
6. validate the archive before extraction;
7. replace the managed destination from a fresh extraction;
8. create or update `.codingstandardrc` with concrete provenance;
9. update repository-facing governance so applicable standards are mandatory;
10. create a branch from the current default branch; and
11. propose the complete change as a pull request against the default branch.

The operation must fail rather than improvise when the requested release does not
exist, either required release artifact is missing, the checksum does not match,
the archive is unsafe, or the target repository cannot safely receive the proposed
change.

The actor must not silently substitute `main`, a GitHub-generated source archive,
or another release when the requested release artifact is unavailable.

### Pull-request adoption

Initial adoption, upgrades, downgrades, refreshes, and same-version repairs are
normal repository changes and should be reviewable before they become governance.

The pull request should identify at least:

- the requested version selector;
- the resolved concrete version;
- the prior version when one exists;
- the source repository;
- the verified SHA-256 digest;
- the managed destination; and
- whether the change is an initial adoption, upgrade, downgrade, refresh, or
  repair.

Directly modifying a consumer's default branch is not the reference adoption
model.

### Consumer governance

A consuming repository that adopts these standards must explicitly identify the
applicable content under `doc/standards/` as governance rather than suggestions.
Repository-facing instructions such as `AGENTS.md`, `README.md`, and
`CONTRIBUTING.md` should be updated when appropriate so both coding agents and
human contributors understand the requirement.

A suitable baseline rule is:

> Files under `doc/standards/` are governing project requirements, not
> suggestions.  Apply every relevant standard unless an accepted
> repository-specific ADR or explicit repository policy supersedes or refines it.
> Do not silently deviate from a governing standard.  Do not edit the imported
> standards locally; project-specific exceptions belong in repository governance.

Presence does not imply applicability.  The complete standards library is shipped
in every release so packaging does not need to encode repository-specific policy.
General and cross-cutting standards apply where relevant.  Language-specific
standards apply to maintained content in that language.  Content under
`examples/` is illustrative and non-normative unless another standard explicitly
states otherwise.

Repository-specific accepted ADRs and explicit local policy may refine or
supersede imported standards for that repository.  Such exceptions must be
visible governance decisions, not undocumented deviations or local edits to the
managed standards files.

## Alternatives Considered

### Consumer-side update workflow

ADR-002 selected a manually dispatched GitHub Actions workflow installed in each
consumer.

This was rejected for the continuing design because it makes every consuming
repository carry and maintain update machinery for a dependency that changes
infrequently.  A coding agent or maintainer can perform the same operation through
ordinary GitHub repository and release interfaces and produce the same reviewable
pull request without installing a downloader into the consumer.

### Bashdeps and Make in each consumer

The original distribution architecture used Bashdeps to acquire the archive and
Make to materialize the standards.

This remains technically possible, but it is no longer part of the reference
consumer contract.  It introduces executable tooling, manifests, bootstrap logic,
and maintenance responsibilities into repositories whose durable requirement is
only the committed standards snapshot and provenance.

### Git submodules

Submodules provide a precise upstream Git commit but do not guarantee that the
standards files are present in an ordinary checkout.  They also expose the source
repository layout rather than the released standards artifact and make parent
repository diffs less useful for reviewing governance changes.

### GitHub-generated source archives

GitHub automatically provides source `.tar.gz` and `.zip` archives for tags.

They were rejected as the release contract because they contain the entire
repository under an outer generated directory and do not provide the deliberately
constructed release archive or its companion checksum.  Consumers should use the
published `coding_standards.tar.gz` artifact instead.

### Persisting `latest`

Persisting `latest` would make the consumer's governing version change meaning over
time.  The selector is therefore resolved to one concrete release before any
repository state is written.

### Overlay extraction

Extracting a newer release over an existing `doc/standards/` directory can retain
files removed upstream.  Fresh replacement is required so the managed tree
converges on the selected release exactly.

## Consequences

### Positive

- Each release has one complete standards archive and one checksum.
- `make all` is the single local and CI build interface for release artifacts.
- Stable filenames make release URLs predictable.
- `dist/` remains generated and untracked.
- Consumers contain governance and provenance rather than updater machinery.
- The complete standards snapshot is available to restricted and offline coding
  agents from an ordinary repository checkout.
- `latest` remains convenient while committed state stays reproducible.
- Repeating an adoption operation repairs drift even when the recorded version is
  unchanged.
- Standards changes remain visible as normal pull-request diffs in each consumer.

### Negative

- Adoption depends on an external maintainer, agent, or tool to perform the update.
- Consuming repositories commit derivative copies of the standards library.
- Single-language consumers receive standards for languages that do not apply to
  them.
- The release archive and checksum must be available before a version can be
  adopted through the reference protocol.

## Compatibility and Migration

Previously published release assets remain historical artifacts and are not
rewritten.

Future releases governed by this ADR publish:

```text
coding_standards.tar.gz
coding_standards.tar.gz.sha256
```

A repository using the ADR-002 consumer-workflow model may migrate by removing its
standards-specific updater workflow and other fetch machinery, retaining or
replacing the committed `doc/standards/` tree from a released artifact, creating
`.codingstandardrc`, and updating local governance to describe the managed
standards as requirements.

Repositories already containing committed standards do not need network access for
normal development after adoption.

## Expected Outcome

A release of this repository produces two deterministic, untracked files through
`make all`, and the GitHub Release publishes those exact files as assets.  A
consumer can then be told to use a concrete version or the latest coding standards,
and a maintainer or coding agent can deterministically verify the release, replace
`doc/standards/`, record provenance in `.codingstandardrc`, establish the standards
as repository governance, and propose the adoption through a pull request.
