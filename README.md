# Coding Standards

This repository is the canonical home for reusable coding, documentation, and
repository standards used across projects maintained by Wesley Dean.

The standards are written primarily in Markdown so they can be read directly by
people, consumed by coding agents and LLMs, rendered as documentation, and
materialized into other repositories as ordinary project files.

The intent is to keep shared engineering guidance in one authoritative location
while allowing each consuming repository to carry a pinned, reviewable copy of a
released standards profile.

## Goals

This repository is intended to provide standards that are:

- explicit enough to guide both human developers and coding agents;
- reusable across multiple repositories;
- inspectable and reviewable as ordinary text;
- versionable through Git;
- consumable as coherent released profiles;
- suitable for offline use after synchronization; and
- accompanied by concrete examples where examples improve understanding.

A consuming project may use a language-specific standards profile or the complete
`all` profile when multiple languages are governed by the repository.

## Repository Structure

`standards/` is the distributable source root.  Normative standards and their
non-normative examples live beneath the same namespace so consumers can
materialize the complete governed tree beneath `doc/standards/`.

The current and anticipated structure is:

```text
standards/
├── general/
│   ├── clean-architecture-standard.md
│   ├── clean-coding-standard.md
│   └── conventional-commit-release-governance.md
├── awk/
│   └── documentation-standard.md
├── bash/
│   ├── coding-standard.md
│   ├── documentation-standard.md
│   ├── testing-standard.md
│   └── tooling-standard.md
├── php/
│   └── documentation-standard.md
├── python/
│   └── documentation-standard.md
├── markdown/
│   └── markdown-standard.md
├── repository/
│   ├── repository-standard.md
│   └── github-standard.md
├── adr/
│   └── adr-standard.md
└── examples/
    ├── general/
    │   └── clean-coding/
    │       └── bash.md
    ├── awk/
    │   └── documentation/
    │       └── example.awk
    ├── bash/
    │   └── documentation/
    │       └── example.bash
    ├── php/
    │   └── documentation/
    │       └── example.php
    ├── python/
    │   └── documentation/
    │       └── example.py
    ├── markdown/
    ├── repository/
    └── adr/
```

Some anticipated categories may not yet contain tracked files.  Their place in
the distribution model is nevertheless explicit so later additions do not
require consumers to redesign how standards are acquired.

The `standards/general/` tree contains standards that apply across languages or
engineering contexts unless a more specific standard takes precedence.
Language-specific standards may refine those general standards and should state
their precedence relationship explicitly when necessary.

The language-independent cross-cutting profile categories are:

```text
general
markdown
repository
adr
```

The currently published language profiles are:

```text
awk
bash
php
python
```

The `standards/` category trees contain normative guidance.  The
`standards/examples/` tree contains illustrative material demonstrating how the
standards may be applied.

Examples never supersede standards.  If an example and a standard disagree, the
standard is authoritative and the example should be corrected.

## Current Standards

The repository currently includes:

- [Clean Architecture Standard](standards/general/clean-architecture-standard.md),
  a language-independent architectural standard covering dependency direction,
  separation of policy from mechanism, explicit boundaries, dependency inversion,
  stable dependencies, replaceability, testability, domain language, and durable
  architectural decisions.
- [Clean Coding Standard](standards/general/clean-coding-standard.md), a
  language-independent standard covering function responsibilities,
  Command-Query Separation, levels of abstraction, side effects, naming, control
  flow, duplication, comments, error behavior, and readability.
- [Conventional Commit and Release Versioning Governance](standards/general/conventional-commit-release-governance.md),
  a repository-wide governance standard for Conventional Commit titles, pull
  request and merge title semantics, trusted release classification, and
  deterministic Semantic Versioning significance.
- [AWK Documentation Standard](standards/awk/documentation-standard.md), a
  language-specific source-documentation standard for maintained AWK files,
  including `awk-doxygen` conventions, function and rule contracts, global state,
  portability, `getline`, record semantics, subprocess boundaries, and generated
  reference documentation.
- [Bash Documentation Standard](standards/bash/documentation-standard.md), a
  language-specific source-documentation standard for maintained Bash files,
  including `bash-doxygen` conventions, file and function contracts, STDIN,
  STDOUT, STDERR, return and exit-status semantics, side effects, security
  boundaries, ADR relationships, and generated reference documentation.
- [PHP Documentation Standard](standards/php/documentation-standard.md), a
  Doxygen-first PHP documentation standard using PHPDoc/Javadoc-style DocBlocks,
  the common Doxygen/phpDocumentor tag subset, native PHP type declarations, and
  direct Doxygen consumption without a translation filter.  phpDocumentor
  compatibility is preferred where it does not conflict with Doxygen.
- [Python Documentation Standard](standards/python/documentation-standard.md), a
  language-specific source-documentation standard using PEP 257 structure,
  Sphinx/reStructuredText fields, type annotations, Python-native linting, and
  `python-doxygen` for the Doxygen-facing structured documentation contract.

## Documentation Tooling

The Bash, AWK, and Python documentation standards are paired with
language-specific Doxygen filters maintained in separate repositories:

- [bash-doxygen](https://github.com/wesley-dean/bash-doxygen) translates the
  documented Bash subset into a Doxygen-friendly representation.
- [awk-doxygen](https://github.com/wesley-dean/awk-doxygen) translates the
  documented AWK subset into a Doxygen-friendly representation.
- [python-doxygen](https://github.com/wesley-dean/python-doxygen) preserves
  Python as the source language while implementing the Doxygen-facing structured
  documentation portion of the Python standard.

PHP is intentionally different.  The PHP standard uses a Doxygen-first subset of
PHPDoc/Javadoc-style DocBlocks that Doxygen can consume directly, so no PHP
translation filter is part of the baseline architecture.  phpDocumentor
compatibility is a secondary benefit of the shared syntax, not a governing
requirement.

The standards in this repository remain authoritative for maintained source.
Each filter repository governs its supported syntax, conservative recognition
boundary, diagnostics, generated representation, and release behavior through its
own ADRs and tests.

For Python, `python-doxygen` implements the standard's governed Doxygen-facing
structured documentation forms, including parameter, return, exception, yield,
and intentionally unannotated type fields.  Semantic validation of Python
signatures, annotations, type correctness, return or exception behavior, and
documentation/signature agreement remains with Python-native tooling such as
Pylint rather than with the AWK translation filter.

Related examples include:

- [Clean Coding Examples for Bash](standards/examples/general/clean-coding/bash.md).
- [AWK Documentation Example](standards/examples/awk/documentation/example.awk),
  a non-normative AWK program demonstrating file, function, global-state, and rule
  documentation from the AWK standard.
- [Bash Documentation Example](standards/examples/bash/documentation/example.bash),
  a non-normative Bash file demonstrating file, variable, function, stream,
  return, and exit-status documentation from the Bash standard.
- [PHP Documentation Example](standards/examples/php/documentation/example.php),
  a non-normative PHP file demonstrating representative Doxygen-first DocBlocks
  using the common PHPDoc-compatible subset.
- [Python Documentation Example](standards/examples/python/documentation/example.py),
  a non-normative module demonstrating representative forms from the Python
  documentation standard.

## Distribution Bundles

The preferred distribution interface is a released profile archive rather than a
set of raw GitHub content URLs.

The bundle design is governed by
[ADR-001](doc/adr/ADR-001-standards-distribution-bundles.md).

Each language bundle contains:

1. every existing common category (`general`, `markdown`, `repository`, and
   `adr`);
2. the selected language category;
3. examples for the included common categories; and
4. examples for the selected language.

The `all` profile contains the complete contents of `standards/` and is the
recommended profile for repositories governed by more than one language standard.

Release assets use stable names because the release tag supplies the version:

```text
coding-standards-all.tar.gz
coding-standards-all.tar.gz.sha256
coding-standards-awk.tar.gz
coding-standards-awk.tar.gz.sha256
coding-standards-bash.tar.gz
coding-standards-bash.tar.gz.sha256
coding-standards-php.tar.gz
coding-standards-php.tar.gz.sha256
coding-standards-python.tar.gz
coding-standards-python.tar.gz.sha256
```

Archives do not contain an outer `standards/` directory.  For example, the Bash
archive is rooted like this:

```text
general/
bash/
markdown/
repository/
adr/
examples/
```

Only categories containing tracked files appear in a particular release.
Extracting the archive beneath `doc/standards/` therefore produces paths such as:

```text
doc/standards/general/
doc/standards/bash/
doc/standards/examples/
```

This keeps examples of the shared standards distinct from any `doc/examples/`
content owned by the consuming project.

### Building Bundles Locally

Generate all profile archives and checksum files with:

```bash
make dist
```

Verify that two builds from the same source tree produce the same archive digests
with:

```bash
make dist-check
```

Generated artifacts are written beneath `dist/` and are not committed.

The bundle builder normalizes archive ordering, timestamps, ownership metadata,
and filesystem modes.  It rejects symbolic links in the distributable standards
tree and validates generated paths before emitting checksums.

### CI and Releases

Pull requests and pushes to `main` run `make dist-check` and publish the generated
bundles as short-lived GitHub Actions artifacts for inspection.

Pushing a `v*` tag runs the same deterministic build and creates a GitHub Release
containing the `.tar.gz` profiles and their `.sha256` files.  The release workflow
refuses to replace an existing release.  A bad published artifact must be fixed in
source and released under a new version.

## Consuming a Released Profile with bashdeps

[bashdeps](https://github.com/wesley-dean/bashdeps) remains responsible for
acquiring and SHA-256-verifying the exact released archive.  The consuming
repository's Make integration is responsible for interpreting that verified
archive and materializing it beneath `doc/standards/`.

The boundary is deliberate:

```text
bashdeps
    acquires and verifies exact bytes

Make
    extracts and replaces the managed standards tree
```

A Bash consumer might declare one dependency in `dependencies-standards.txt`:

```text
id=wesley-dean/coding_standards/bash@v1.2.0 \
  url=https://github.com/wesley-dean/coding_standards/releases/download/v1.2.0/coding-standards-bash.tar.gz \
  dest=vendor/coding-standards-bash.tar.gz \
  digest=sha256:<reviewed-sha256-digest>
```

The upstream `.sha256` file is useful release metadata, but the digest committed
in the consuming repository remains that repository's authority for acceptable
bytes.

Synchronize the archive with:

```bash
vendor/bashdeps.bash sync dependencies-standards.txt
```

Verify the cached archive without network access with:

```bash
vendor/bashdeps.bash verify dependencies-standards.txt
```

### Materializing `doc/standards/`

A consumer must replace the managed standards tree from a fresh extraction rather
than extracting a new version over the existing directory.  Otherwise a standard
removed from a later release could remain locally and appear current.

A representative Make integration is:

```make
BASHDEPS ?= vendor/bashdeps.bash
STANDARDS_ARCHIVE := vendor/coding-standards-bash.tar.gz
STANDARDS_DIR := doc/standards

.PHONY: standards standards-check

standards: dependencies-standards.txt
	"$(BASHDEPS)" sync dependencies-standards.txt
	@set -eu; \
	parent="$$(dirname -- "$(STANDARDS_DIR)")"; \
	mkdir -p -- "$$parent"; \
	tmp="$$(mktemp -d "$$parent/.standards.XXXXXX")"; \
	trap 'rm -rf -- "$$tmp"' EXIT HUP INT TERM; \
	tar -xzf "$(STANDARDS_ARCHIVE)" -C "$$tmp"; \
	rm -rf -- "$(STANDARDS_DIR).new"; \
	mv -- "$$tmp" "$(STANDARDS_DIR).new"; \
	trap - EXIT HUP INT TERM; \
	rm -rf -- "$(STANDARDS_DIR)"; \
	mv -- "$(STANDARDS_DIR).new" "$(STANDARDS_DIR)"

standards-check: dependencies-standards.txt
	"$(BASHDEPS)" verify dependencies-standards.txt
	@set -eu; \
	tmp="$$(mktemp -d)"; \
	trap 'rm -rf -- "$$tmp"' EXIT HUP INT TERM; \
	tar -xzf "$(STANDARDS_ARCHIVE)" -C "$$tmp"; \
	diff -r "$$tmp" "$(STANDARDS_DIR)"
```

A consuming repository may use a different implementation if its platform or
build system requires one.  The important contract is that the archive is first
verified as an exact dependency, materialization starts from a fresh tree, and
`doc/standards/` can be checked against the selected archive when that archive is
available locally.

### Committing the materialized standards

The materialized `doc/standards/` tree should be committed to the consuming
repository.  It is externally managed content, but it is intentionally part of
the repository checkout rather than an ephemeral build product.

This matters for coding agents and restricted development containers.  Such an
environment may have no direct DNS or HTTPS access to GitHub even when the hosting
product offers a GitHub connector.  Bashdeps is an ordinary local Bash program
and cannot implicitly use that connector, so agent startup must not depend on a
fresh network download of the standards bundle.

The intended lifecycle is:

```text
networked maintainer workstation or CI
    -> bashdeps acquires and verifies the pinned bundle
    -> Make materializes a fresh doc/standards/ tree
    -> the dependency declaration and standards tree are reviewed and committed

coding agent or offline developer
    -> repository checkout already contains doc/standards/
    -> governing standards are available before work begins
```

A standards update should therefore produce an ordinary repository change showing
both the selected release/digest update and the exact Markdown changes being
adopted.  Project instructions such as `AGENTS.md` can then point directly at
`doc/standards/` without requiring a network bootstrap step.

The verified archive itself does not have to be committed.  If it is absent, an
offline container cannot re-run a check that depends on the archive, but it can
still perform normal development because the governing standards are already
present in the checkout.  Re-materialization belongs on a network-capable
maintainer system or CI runner.

For a repository that uses several governed languages, prefer
`coding-standards-all.tar.gz` rather than overlaying several language bundles.
This avoids duplicate common categories and ensures the complete standards tree
comes from one release.

Direct per-file bashdeps declarations remain technically possible, but they are
not the preferred distribution interface.  Consumers should normally depend on a
released profile rather than reproduce this repository's internal file inventory.

## Using Vendored Standards in a Project

Once materialized and committed, the files under `doc/standards/` are ordinary
repository files and can be read by developers, reviewers, coding agents, CI jobs,
or documentation tooling without contacting this repository.

A consuming repository may direct coding agents to them from `AGENTS.md`, for
example:

```markdown
Before modifying source, read the applicable standards under `doc/standards/`.

Files under `doc/standards/` are materialized from a pinned coding-standards
release archive.  Do not modify synchronized standards locally.
Repository-specific exceptions or superseding decisions must be documented
through this repository's normal governance process.
```

Repository-specific requirements remain local to the consuming repository.  A
shared standard should not be edited locally to accommodate one project.
Project-specific exceptions, refinements, or superseding decisions should instead
be documented through that project's normal governance process.

## Governance

Consequential repository decisions are recorded as ADRs beneath `doc/adr/`.
Concise decision summaries are maintained in [doc/decisions.md](doc/decisions.md).

The current distribution and materialization contract is governed by
[ADR-001: Distribute Standards as Profile Archives](doc/adr/ADR-001-standards-distribution-bundles.md).

## GitHub Pages

The Markdown in this repository may also be published through GitHub Pages so the
standards and examples are convenient to browse outside the GitHub source view.

The published site should be treated as a presentation of repository content, not
as a separate source of truth.  Standards and examples continue to be maintained
beneath `standards/`, and any site-generation layer should render or link to those
files rather than maintain duplicate copies.

A future GitHub Pages configuration may provide:

- navigation by language or engineering concern;
- links between each standard and its examples;
- rendered code examples;
- links back to exact source files in GitHub; and
- clear identification of the revision or release represented by the site.

The repository deliberately does not require a particular static-site generator.
GitHub Pages can be added after documentation structure and navigation needs are
better established.

## Source of Truth

The maintained files beneath `standards/` are the canonical shared standards and
examples.  Generated bundle archives, published checksums, GitHub Actions
artifacts, GitHub Release assets, and copies materialized into consuming
repositories are derivative artifacts.

Changes to a shared standard are made here, reviewed here, released here, and
adopted explicitly by consuming repositories by updating the selected bundle
version, committed digest, and committed materialized `doc/standards/` tree.

This keeps standards changes visible in both places: once when the shared standard
changes, and again when an individual project chooses to adopt the released
change.
