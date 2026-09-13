# ADR-001: Distribute Standards as Profile Archives

## Status

Accepted

## Context

The coding standards repository is intended to be the canonical source for reusable engineering standards that can be consumed by humans, coding agents, CI systems, and other repositories.  The initial consumption model treated each standard as an independent external file.  A consuming repository could declare every desired Markdown file in a bashdeps manifest, point each declaration at a raw GitHub content URL, and materialize the files beneath `doc/standards/`.

That model preserves exact-file verification, but it makes adoption unnecessarily cumbersome.  A consumer must know every file that belongs to the desired standards set, repeat a raw-content URL and SHA-256 digest for each file, and update the manifest whenever the canonical standards set gains or removes a file.  The consumer is therefore coupled to the repository's internal file inventory rather than to a deliberate released standards profile.

A second possibility was to publish bashdeps manifests from this repository and have a consumer use bashdeps to acquire the appropriate manifest before invoking bashdeps again on that downloaded manifest.  This would reduce hand-maintained file lists in the consumer, but it would introduce a two-stage dependency process and make a manifest itself a bootstrap dependency.  The resulting workflow would be more difficult to explain, audit, update, and recover when versions become inconsistent.

Bashdeps intentionally operates at a lower level.  One dependency record identifies one exact external artifact, its project-relative destination, and its trusted SHA-256 digest.  Bashdeps verifies and materializes bytes; it does not infer artifact semantics and it does not extract archives.  The standards distribution model should preserve that boundary rather than add recursive-manifest or archive-extraction behavior to bashdeps.

The repository also originally stored examples in a top-level `examples/` tree parallel to `standards/`.  When the canonical standards are materialized into another repository, that layout naturally suggests `doc/examples/`, which can be mistaken for examples belonging to the consuming project.  The examples are examples *of the standards* and should travel with those standards under the same namespace.

The standards are small text artifacts.  Optimizing for the minimum number of downloaded bytes is less important than making the adopted standards set explicit, versioned, reviewable, easy to update, and difficult to assemble incorrectly.

## Decision

The repository will distribute versioned standards bundles as deterministic `.tar.gz` release artifacts.

### Canonical source layout

`standards/` is the distributable source root.  Normative standards remain organized by category or language beneath that directory.

Illustrative examples are maintained beneath:

```text
standards/examples/
```

rather than in a repository-level `examples/` directory.

The examples remain non-normative.  When an example conflicts with a standard, the standard governs.

### Common categories

The following categories are common standards categories:

```text
general
markdown
repository
adr
```

A common category is included in every language profile when that category exists in the source tree.  This explicit list prevents a newly added language directory from being silently treated as common merely because packaging logic did not yet know about it.

Adding or removing a common category is a distribution-contract change and must update the bundle configuration deliberately.

### Language profiles

The initial language profiles are:

```text
awk
bash
php
python
```

Each language bundle contains:

1. every existing common standards category;
2. the selected language-specific standards category;
3. examples corresponding to the included common categories; and
4. examples corresponding to the selected language.

For example, the Bash bundle conceptually contains:

```text
general/
bash/
markdown/
repository/
adr/
examples/general/
examples/bash/
examples/markdown/
examples/repository/
examples/adr/
```

Directories for categories that do not yet contain tracked files are naturally absent from the archive.  When a common category later gains tracked standards or examples, subsequent language bundles include it automatically through the explicit common-category configuration.

### All profile

The repository also publishes an `all` bundle containing the complete contents of `standards/`.

Multi-language consuming repositories should normally use the `all` profile rather than overlay multiple language bundles.  This avoids overlapping copies of common standards and gives the consumer one coherent standards version.

### Artifact names

Release assets use stable names because the GitHub release tag already identifies the version:

```text
coding-standards-all.tar.gz
coding-standards-awk.tar.gz
coding-standards-bash.tar.gz
coding-standards-php.tar.gz
coding-standards-python.tar.gz
```

Each archive is accompanied by a SHA-256 checksum file using the same name with `.sha256` appended.

The checksum published by this repository is release metadata.  A consuming repository that uses bashdeps still commits the digest it has reviewed into its own bashdeps manifest.  Bashdeps does not dynamically trust or replace a committed digest from the live upstream checksum file.

### Archive root

Archives do not contain an outer `standards/` directory.  Their root contains the selected categories directly:

```text
general/
bash/
examples/
...
```

A consumer can therefore extract the verified archive into `doc/standards/` and obtain:

```text
doc/standards/general/
doc/standards/bash/
doc/standards/examples/
...
```

This layout deliberately keeps examples under `doc/standards/examples/`, where their relationship to the vendored standards is unambiguous.

### Deterministic generation

Bundle generation is deterministic for a fixed Git tree and build-tool behavior.  The build process:

- sorts archive members by name;
- normalizes archived modification times;
- normalizes ownership metadata;
- normalizes file and directory modes;
- suppresses gzip filename and timestamp metadata;
- rejects symbolic links in the maintained standards tree; and
- validates archive paths so an archive cannot contain absolute paths, parent-directory traversal, or an accidental outer `standards/` prefix.

CI builds the bundles repeatedly and compares their checksums to detect loss of deterministic behavior.

### Release publication

A tagged release publishes the generated profile archives and checksum files as GitHub Release assets.

Published release assets are treated as immutable.  If an already published bundle is wrong, the correction is made in source and published under a new release rather than silently replacing the bytes associated with an existing version.

### Consumer acquisition and materialization

A consuming repository declares one selected bundle as a bashdeps dependency.  The archive itself normally lives beneath `vendor/`, which preserves bashdeps' default destination boundary.

Conceptually:

```text
bashdeps
    acquires and SHA-256-verifies the selected archive

Make
    interprets the verified archive and materializes it into doc/standards/
```

Bashdeps remains responsible only for exact artifact acquisition and verification.  It does not gain archive-extraction behavior.

The consumer's materialization step extracts into a temporary directory and replaces the managed `doc/standards/` tree with the newly extracted tree.  It must not merely extract a new archive over the existing directory because files removed from a later standards release would otherwise remain as stale local state.

A consuming repository may expose targets such as `standards` and `standards-check`.  The exact Make integration belongs to that repository, but the intended responsibilities are:

- `standards`: synchronize the pinned archive with bashdeps, safely extract it into a fresh tree, and replace the prior `doc/standards/` tree;
- `standards-check`: verify the pinned archive with bashdeps and verify that `doc/standards/` matches the contents of that archive.

### Source of truth

The maintained files beneath `standards/` remain the canonical source of truth.  Generated archives, published checksum files, and materialized copies in consuming repositories are derivative artifacts.

Changes to shared standards are made and reviewed in this repository, released here, and adopted explicitly by consumers by updating their pinned bundle version and committed digest.

## Alternatives Considered

### Declare every standard file directly in each consumer

This was the initial approach.

It preserves exact per-file verification and requires no packaging layer.  It was rejected as the primary distribution model because every consumer must reproduce the canonical file inventory, raw GitHub URLs, destinations, and digests.  Adding one shared standard creates update work in every consumer even when the consumer conceptually depends on a single standards profile.

Direct per-file declarations remain technically possible, but they are not the recommended integration.

### Publish language-specific bashdeps manifests and run bashdeps twice

This would let a consumer fetch `standards-bash.txt` and then invoke bashdeps on the downloaded manifest.

It was rejected because it creates a recursive dependency workflow, introduces version coordination between the bootstrap manifest and its referenced files, increases the number of network requests, and makes the consumer understand two acquisition stages.  It also turns a release profile into a list of implementation files instead of one reviewable artifact.

### Add archive extraction to bashdeps

This was rejected because extraction is interpretation of artifact content.  Bashdeps intentionally verifies and places exact bytes without inferring their meaning.  Teaching it archive semantics would enlarge its security boundary, require archive path and overwrite policy, and couple a general dependency tool to this repository's materialization needs.

### Extract directly over the existing `doc/standards/` tree

This was rejected because archive extraction does not normally delete files that are absent from the new archive.  A removed or renamed standard could remain in the consumer and appear current even though it no longer belongs to the selected release.

Fresh-tree materialization makes the installed standards set correspond exactly to the selected bundle.

### Publish only one all-inclusive archive

This would be the smallest packaging implementation and would work for every repository.

It was rejected as the only profile because single-language repositories benefit from a clearly scoped bundle that communicates which language standard they adopted.  The `all` profile remains available and is recommended for multi-language repositories.

### Publish independent common and language component archives

For example, a consumer could acquire `general`, `repository`, and `bash` archives separately.

This was rejected because it reintroduces composition and version-skew problems at the consumer.  A language profile should be a complete standards environment rather than a set of pieces every consumer must assemble correctly.

## Consequences

### Positive

- A consumer normally declares one standards dependency rather than many individual files.
- Consumers adopt a deliberate released profile instead of reproducing repository internals.
- General and cross-cutting standards travel automatically with the selected language standard.
- Examples are materialized beneath `doc/standards/examples/`, avoiding ambiguity with consumer-owned examples.
- One bundle version and one committed digest describe the adopted standards environment.
- Bashdeps keeps its existing exact-artifact trust and responsibility boundary.
- Removed standards do not remain behind when consumers use fresh-tree materialization.
- Release bundles can be reviewed, archived, mirrored, and verified independently of GitHub's raw-content interface.
- The `all` profile gives multi-language repositories a coherent single-version standards set.

### Negative

- The repository gains packaging and release automation.
- Consumers need `tar` and gzip support in addition to bashdeps when materializing the bundle.
- A change to any common standard changes every language bundle's bytes and therefore requires consumers adopting a new release to update their committed digest.
- Language bundles contain some standards a particular project may not actively use, trading a small amount of extra text for a much simpler adoption model.
- Release correctness now includes archive composition and deterministic-generation behavior.

## Compatibility and Migration

Existing consumers that pin individual standards files may continue doing so until they choose to migrate.

Migration consists of:

1. selecting the appropriate language profile or `all` profile;
2. replacing individual standards declarations with one declaration for the released archive;
3. adding consumer-side materialization into `doc/standards/`;
4. verifying the resulting tree against the selected archive; and
5. removing obsolete individually managed standard files.

The source-tree move from top-level `examples/` to `standards/examples/` changes repository paths for examples.  Internal links and repository documentation must be updated as part of the same migration.

No compatibility promise is made that raw GitHub content URLs for individual files are a stable package-management interface.  Released bundle assets are the preferred distribution contract.

## Expected Outcome

A repository adopting the Bash standards, for example, should be able to identify one released `coding-standards-bash.tar.gz` artifact, pin its exact digest with bashdeps, and materialize a complete standards environment beneath `doc/standards/` without knowing the individual file inventory of this repository.

The resulting consumer tree should make provenance obvious: normative standards and their illustrative examples live together beneath `doc/standards/`, while project-owned documentation and examples remain outside that managed namespace.
