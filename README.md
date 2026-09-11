# Coding Standards

This repository is the canonical home for reusable coding, documentation, and
repository standards used across projects maintained by Wesley Dean.

The standards are written primarily in Markdown so that they can be read directly
by people, consumed by coding agents and LLMs, rendered as documentation, and
materialized into other repositories as ordinary project files.

The intent is to keep shared engineering guidance in one authoritative location
while allowing each consuming repository to carry a pinned, reviewable copy of the
standards that govern it.

## Goals

This repository is intended to provide standards that are:

- explicit enough to guide both human developers and coding agents;
- reusable across multiple repositories;
- inspectable and reviewable as ordinary text;
- versionable through Git;
- independently consumable rather than requiring the entire repository;
- suitable for offline use after synchronization; and
- accompanied by concrete examples where examples improve understanding.

A consuming project may adopt all of the standards in a category or only the
specific standards that apply to that project.

## Repository Structure

Standards and examples are kept in parallel top-level trees.

The anticipated structure is:

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
├── python/
│   └── documentation-standard.md
├── markdown/
│   └── markdown-standard.md
├── repository/
│   ├── repository-standard.md
│   └── github-standard.md
└── adr/
    └── adr-standard.md

examples/
├── general/
│   └── clean-coding/
│       └── bash.md
├── awk/
├── bash/
│   ├── coding/
│   ├── documentation/
│   ├── testing/
│   └── tooling/
├── python/
├── markdown/
├── repository/
└── adr/
```

This structure is intentionally extensible.  Additional languages, formats, or
engineering concerns can be added without changing the basic organization.

The `standards/general/` tree contains standards that apply across languages or
engineering contexts unless a more specific standard takes precedence.
Language-specific standards may refine those general standards and should state
their precedence relationship explicitly when necessary.

The `standards/` tree contains normative guidance.  The `examples/` tree contains
illustrative material that demonstrates how the standards may be applied.

Examples do not supersede the standards.  If an example and a standard disagree,
the standard is authoritative and the example should be corrected.

A standard should link to relevant examples when those examples materially help a
reader understand or apply the rule.  Examples may include conforming code,
non-conforming code, before-and-after comparisons, complete small projects,
configuration fragments, or other useful demonstrations.

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
- [Python Documentation Standard](standards/python/documentation-standard.md), a
  language-specific source-documentation standard using PEP 257 structure,
  Sphinx/reStructuredText fields, type annotations, and a `python-doxygen`
  translation boundary so maintained docstrings remain native to Python tooling
  while producing structured Doxygen reference documentation.

Related examples include:

- [Clean Coding Examples for Bash](examples/general/clean-coding/bash.md).

## Consuming Standards with bashdeps

[bashdeps](https://github.com/wesley-dean/bashdeps) can materialize individual
standards into another repository as pinned, SHA-256-verified external artifacts.
This allows a consuming repository to carry the exact standards that govern it
without using Git submodules or requiring network access during ordinary
development.

A consuming repository might use this layout:

```text
dependencies-standards.txt

doc/
└── standards/
    ├── clean-architecture-standard.md
    ├── clean-coding-standard.md
    ├── conventional-commit-release-governance.md
    ├── awk-documentation-standard.md
    ├── bash-coding-standard.md
    ├── bash-documentation-standard.md
    ├── bash-testing-standard.md
    └── python-documentation-standard.md
```

The standards manifest is an ordinary bashdeps manifest.  For example:

```text
id=wesley-dean/coding_standards/clean-coding@<ref> \
  url=https://raw.githubusercontent.com/wesley-dean/coding_standards/<ref>/standards/general/clean-coding-standard.md \
  dest=doc/standards/clean-coding-standard.md \
  digest=sha256:<sha256-digest>

id=wesley-dean/coding_standards/bash-coding@<ref> \
  url=https://raw.githubusercontent.com/wesley-dean/coding_standards/<ref>/standards/bash/coding-standard.md \
  dest=doc/standards/bash-coding-standard.md \
  digest=sha256:<sha256-digest>
```

`<ref>` should identify immutable reviewed source, such as a Git commit or an
immutable release tag.  The committed SHA-256 digest remains the consuming
repository's authority for the exact bytes it accepts.

The standards can then be synchronized with:

```bash
vendor/bashdeps.bash sync \
  --dest-root doc/standards \
  dependencies-standards.txt
```

Existing local state can be verified without network access with:

```bash
vendor/bashdeps.bash verify \
  --dest-root doc/standards \
  dependencies-standards.txt
```

The explicit `--dest-root doc/standards` boundary is intentional.  It limits the
standards manifest to managing files beneath the consuming repository's standards
directory.

A project using Make may expose these operations as repository-level targets:

```make
.PHONY: standards standards-check

standards: $(BASHDEPS) dependencies-standards.txt
	$(MAKE) --no-print-directory verify-bashdeps
	"$(BASHDEPS)" sync \
		--dest-root doc/standards \
		dependencies-standards.txt

standards-check: verify-bashdeps dependencies-standards.txt
	"$(BASHDEPS)" verify \
		--dest-root doc/standards \
		dependencies-standards.txt
```

The exact Make integration belongs to the consuming repository.  bashdeps is
responsible for determining whether the declared bytes are present and acceptable;
the consuming project decides when and why its standards are synchronized.

## Using Vendored Standards in a Project

Once synchronized, the files under `doc/standards/` are ordinary repository files
and can be read by developers, reviewers, coding agents, CI jobs, or documentation
tooling without contacting this repository.

A consuming repository may direct coding agents to them from `AGENTS.md`, for
example:

```markdown
Before modifying Bash source, read the applicable standards under
`doc/standards/`.

Files under `doc/standards/` are synchronized from the canonical standards
repository through `dependencies-standards.txt` using bashdeps.  Do not modify
synchronized standards locally.  Repository-specific exceptions or superseding
decisions must be documented through this repository's normal governance process.
```

Repository-specific requirements remain local to the consuming repository.  A
shared standard should not be edited locally to accommodate one project.
Project-specific exceptions, refinements, or superseding decisions should instead
be documented through that project's normal governance process.

## GitHub Pages

The Markdown in this repository may also be published through GitHub Pages so the
standards and examples are convenient to browse outside the GitHub source view.

The published site should be treated as a presentation of repository content, not
as a separate source of truth.  Standards should continue to be maintained in the
`standards/` tree, examples should continue to be maintained in the `examples/`
tree, and any site-generation layer should render or link to those files rather
than maintain duplicate copies.

A future GitHub Pages configuration may provide:

- navigation by language or engineering concern;
- links between each standard and its examples;
- rendered code examples;
- links back to the exact source files in GitHub; and
- clear identification of the revision or release represented by the site.

The initial repository layout deliberately does not require a particular static
site generator.  GitHub Pages can be added after the documentation structure and
navigation needs are better established.

## Source of Truth

The files in this repository are the canonical standards.  Copies materialized
into consuming repositories are pinned snapshots and should not be edited in
place.

Changes to a shared standard should be made here, reviewed here, and then adopted
explicitly by consuming repositories by updating their bashdeps declarations and
committed digests.

This keeps standards changes visible in both places: once when the shared standard
changes, and again when an individual project chooses to adopt that change.
