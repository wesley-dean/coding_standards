# Coding Standards

This repository is the canonical home for reusable coding, documentation, and
repository standards used across projects maintained by Wesley Dean.

The standards are written primarily in Markdown so they can be read directly by
people, consumed by coding agents and LLMs, rendered as documentation, and
materialized into other repositories as ordinary project files.

The intent is to keep shared engineering guidance in one authoritative location
while allowing each consuming repository to carry a pinned, reviewable copy of a
specific released standards version.

## Goals

This repository provides standards that are:

- explicit enough to guide both human developers and coding agents;
- reusable across multiple repositories;
- inspectable and reviewable as ordinary text;
- versioned through Git and Semantic Versioning releases;
- distributed as one coherent standards library per release;
- available to offline or restricted development environments after adoption; and
- accompanied by concrete examples where examples improve understanding.

Every release distributes the complete standards library.  A consuming repository
decides which standards apply through its own governance rather than through
packaging subsets.

## Repository Structure

`standards/` is the distributable source root.  Normative standards and their
non-normative examples live beneath the same namespace so consumers can
materialize the complete released tree beneath `doc/standards/`.

Representative structure:

```text
standards/
├── general/
├── awk/
├── bash/
├── javascript/
├── php/
├── python/
├── markdown/
├── repository/
├── adr/
└── examples/
```

The `standards/general/` tree contains cross-cutting standards that apply across
languages or engineering contexts unless a more specific standard takes
precedence.

Language-specific standards refine general standards for maintained content in
that language where applicable.

The `standards/examples/` tree contains illustrative material demonstrating how
the standards may be applied.  Examples are non-normative.  If an example and a
standard disagree, the standard is authoritative and the example should be
corrected.

## Current Standards

The repository includes standards covering areas such as:

- clean architecture;
- clean coding;
- Conventional Commit and release-versioning governance;
- development workflow, scope, and backlog governance;
- cross-language testing, CI reporting, and test-result publication;
- AWK documentation;
- Bash documentation;
- Bash/Bats behavioral testing, including Bats as a cross-language black-box driver;
- JavaScript documentation;
- PHP documentation;
- Python documentation;
- Markdown;
- repository structure and GitHub conventions; and
- architecture decision records.

The maintained files beneath `standards/` are the source of truth.  Generated
release artifacts and copies adopted into consuming repositories are derivative
representations of a specific released version.

## Documentation Tooling

Some language documentation standards are paired with language-specific Doxygen
filters maintained in separate repositories:

- [bash-doxygen](https://github.com/wesley-dean/bash-doxygen)
- [awk-doxygen](https://github.com/wesley-dean/awk-doxygen)
- [python-doxygen](https://github.com/wesley-dean/python-doxygen)
- [javascript-doxygen](https://github.com/wesley-dean/javascript-doxygen)

The standards in this repository govern the documentation expectations.  Each
filter repository separately governs its supported syntax, diagnostics, generated
representation, and release behavior.

## Release Artifacts

Each standards release publishes exactly two project artifacts:

```text
coding_standards.tar.gz
coding_standards.tar.gz.sha256
```

The archive contains the complete **contents** of `standards/`.  It does not
contain an outer `standards/` directory.

A representative archive root is therefore:

```text
general/
awk/
bash/
javascript/
php/
python/
markdown/
repository/
adr/
examples/
```

Only directories containing tracked files appear in a particular release.
Extracting the archive beneath `doc/standards/` directly produces the managed tree
expected by consuming repositories.

The release-artifact and adoption contract is governed by
[ADR-003: Release Artifacts and Agent-Mediated Standards Adoption](doc/adr/ADR-003-release-artifacts-and-agent-mediated-adoption.md).

### Building Release Artifacts

Use the canonical Make entry point:

```bash
make all
```

A successful build creates:

```text
dist/coding_standards.tar.gz
dist/coding_standards.tar.gz.sha256
```

The `dist/` directory is ignored by Git.  These files are generated build
artifacts and are not committed to the repository.

Archive creation normalizes ordering, timestamps, ownership metadata, filesystem
modes, and gzip metadata.  Symbolic links beneath `standards/` are rejected before
archive creation.

The checksum file contains the SHA-256 digest of the exact archive bytes:

```text
<64-hex-digest>  coding_standards.tar.gz
```

To verify deterministic output from the same source tree, run:

```bash
make dist-check
```

`make dist-check` invokes `make all` twice and verifies that the resulting
checksum is identical.

To remove generated release artifacts, run:

```bash
make clean
```

### Publishing Releases

The repository's semantic-version release workflow runs `make all` before creating
a GitHub Release.

The release attaches these exact files:

```text
coding_standards.tar.gz
coding_standards.tar.gz.sha256
```

The release tag supplies the version identity, so artifact filenames remain stable
across releases.

Published artifacts are treated as immutable.  If a packaging defect is found
after publication, fix the source and publish a new release rather than replacing
an existing release asset in place.

## Adopting Standards in Another Repository

A consuming repository adopts a concrete released version of the complete
standards library.

Typical requests may be phrased as:

```text
Use coding standards v1.4.2 with this repository.
Use the latest coding standards with this repository.
Refresh this repository to the latest coding standards.
```

A request for `latest` is resolved once to the current latest stable GitHub
Release.  The consuming repository records the resulting concrete version rather
than persisting `latest`.

The adoption operation is performed by a maintainer, ChatGPT using the GitHub
connector, another coding agent, or equivalent trusted tooling.  Consuming
repositories do not need to install a standards downloader, updater workflow,
Bashdeps declaration, or Make target merely to hold and use the standards.

### Consumer Provenance

The project root of a consuming repository records the selected release in
`.codingstandardrc`.

Example:

```toml
source = "https://github.com/wesley-dean/coding_standards.git"
version = "coding_standards@v1.4.2"
sha256 = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
destination = "doc/standards"
```

The fields mean:

- `source` identifies this canonical repository;
- `version` identifies the exact released standards version;
- `sha256` records the verified digest of `coding_standards.tar.gz`; and
- `destination` identifies the managed repository-relative standards tree.

The configuration file is data, not executable shell input.

### Managed Standards Tree

The normal destination is:

```text
doc/standards
```

That directory is managed as a complete released snapshot.  An adoption or
refresh replaces it from a fresh extraction of the verified release artifact.
New content is not overlaid onto the previous directory, because doing so could
leave standards that were removed or renamed upstream.

Consumer-specific documentation and exceptions must not be added inside the
managed standards tree.  They belong in the consuming repository's own governance
and documentation.

If the recorded version already matches the requested version but the managed tree
has drifted, repeating the adoption operation restores the exact released content
and proposes the repair for review.

### Governance in Consuming Repositories

A repository that adopts these standards should explicitly tell both humans and
coding agents that applicable files beneath `doc/standards/` are governance, not
suggestions.

A suitable baseline rule is:

> Files under `doc/standards/` are governing project requirements, not
> suggestions.  Apply every relevant standard unless an accepted
> repository-specific ADR or explicit repository policy supersedes or refines it.
> Do not silently deviate from a governing standard.  Do not edit the imported
> standards locally; project-specific exceptions belong in repository governance.

Presence does not imply applicability.  The complete standards library is included
in every release.  General and cross-cutting standards apply where relevant.
Language-specific standards apply to maintained content in that language.
Content under `examples/` is illustrative and non-normative unless another
standard explicitly states otherwise.

Repository-specific accepted ADRs or explicit local policies may refine or
supersede shared standards for that repository.  Such exceptions should be visible
governance decisions rather than undocumented deviations or local edits to
`doc/standards/`.

Repository-facing files such as `AGENTS.md`, `README.md`, and `CONTRIBUTING.md`
should be updated as appropriate when a standards release is adopted so the
repository's governance model is explicit.

### Pull-Request Adoption

Standards adoption is a normal reviewed repository change.

An initial adoption, upgrade, downgrade, refresh, or same-version repair should:

1. resolve the requested release;
2. obtain `coding_standards.tar.gz` and its `.sha256` release asset;
3. verify the archive before extraction;
4. replace the managed standards destination from a fresh extraction;
5. create or update `.codingstandardrc`;
6. reconcile repository-facing governance instructions; and
7. propose the result through a pull request against the repository's default
   branch.

The operation should fail rather than silently substitute `main`, a GitHub source
archive, or a different version when the requested release or required artifact is
unavailable.

The pull request should identify the requested selector, resolved release, prior
release when applicable, verified SHA-256 digest, managed destination, and the type
of adoption operation being proposed.

## Governance

Consequential repository decisions are recorded as ADRs beneath `doc/adr/`.
The curated digest of decisions that currently govern is maintained in
[doc/adr/README.md](doc/adr/README.md), which also provides access to the complete
ADR corpus.

The current release and consumer-adoption contract is governed by
[ADR-003](doc/adr/ADR-003-release-artifacts-and-agent-mediated-adoption.md).

Language-specific standards may have additional accepted decisions.  The
JavaScript documentation standard is governed by
[ADR-004](doc/adr/ADR-004-add-javascript-documentation-standard.md).

ADR acceptance semantics and narrative decision relationships are governed by
[ADR-005](doc/adr/ADR-005-standardize-adr-acceptance-and-decision-summaries.md).
The current-decision landing-page model is governed by
[ADR-006](doc/adr/ADR-006-use-adr-landing-page-for-current-decision-digest.md).
The shared testing model and Bash/Bats refinement are governed by
[ADR-007](doc/adr/ADR-007-adopt-general-testing-and-bats-driver-standards.md).

Earlier superseded distribution ADRs remain as architectural history.

## Source of Truth

The maintained files beneath `standards/` are the canonical standards and
examples.

Changes to a shared standard are made here, reviewed here, released here, and then
adopted explicitly by consuming repositories through a reviewed change to their
pinned standards snapshot.

This keeps standards changes visible in both places: once when the shared standard
changes, and again when an individual project chooses to adopt the released
version.
