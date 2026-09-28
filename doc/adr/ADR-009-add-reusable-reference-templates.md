# ADR-009: Add Reusable Reference Templates

Date: 2026-09-28

## Status

Accepted

## Context

The standards library already distributes three kinds of reusable material:

- normative standards that govern adopted repositories;
- non-normative examples that illustrate how standards may be applied; and
- repository-local files such as GitHub issue and pull-request templates that
  exist only in this repository.

Several standards describe recurring engineering artifacts or interaction
surfaces that repositories recreate independently.  Pull requests, bug reports,
feature requests, general issues, security disclosures, ADRs, commit messages,
and merge messages all benefit from consistent structure.  Recreating those
structures repository by repository increases maintenance cost and makes it more
likely that important context, review boundaries, or governance references will
be omitted.

A reusable template corpus can reduce that duplication, but templates have
different semantics from standards and examples.  A template is neither
normative policy nor merely a completed illustration.  It is a recommended
structure for creating a future artifact.

The distribution model established by ADR-003 also creates an important
boundary.  Standards adoption materializes one managed snapshot beneath
`doc/standards/`.  Extending that operation so it also writes active files such
as `.github/PULL_REQUEST_TEMPLATE.md`, Git configuration, hooks, or workflows
would create a second managed surface, complicate upgrades, and risk overwriting
repository-specific policy.

The repository therefore needs an explicit contract for template semantics,
distribution, local adoption, examples, and maintenance.  Existing repository-local
templates may serve as source material for reusable references without requiring
those active local files to change.

## Decision Drivers

- Provide reusable structures for recurring engineering and governance artifacts.
- Keep normative standards, reference templates, and worked examples distinct.
- Preserve ADR-003's single managed standards snapshot.
- Keep repository-local customization explicit and reviewable.
- Prevent standards adoption from silently mutating active repository surfaces.
- Make templates usable by both humans and automated agents.
- Keep template instructions available while editing without leaving instructional
  prose in the completed artifact.
- Preserve a predictable relationship between templates and their worked examples.
- Support GitHub-facing templates without making the corpus GitHub-only.
- Keep commit and merge guidance useful even where a host or Git client does not
  provide a native Markdown template mechanism.

## Decision

The standards library SHALL add a reusable template corpus beneath:

~~~text
standards/templates/
~~~

Templates are non-normative reference artifacts.  They provide recommended
structure for satisfying or applying governing standards but do not create
requirements independently.

### Artifact Classes

The standards library SHALL distinguish three artifact classes:

1. **standards** define governing requirements;
2. **templates** provide recommended structures for producing recurring
   engineering or governance artifacts; and
3. **examples** show realistic completed applications of standards or templates.

When these artifact classes disagree, the governing standard is authoritative.
A template or example SHALL be corrected rather than used to weaken or redefine
the standard.

### Template Structure

Templates SHALL be maintained as Markdown files.

Instructional guidance SHALL be embedded in Markdown-compatible HTML comments:

~~~markdown
<!-- Explain what belongs here, what may be omitted, and any relevant
governance or security constraints. -->
~~~

Instructional comments SHOULD explain:

- the purpose of the section;
- whether content is required, conditional, or optional;
- relevant governing standards or ADRs where useful;
- information that must not be disclosed publicly; and
- when a section may be removed because it does not apply.

Visible Markdown outside instructional comments should represent the structure
intended to remain in the completed artifact.

Templates SHOULD remain concise enough to use routinely.  Detailed rationale
belongs in standards and ADRs rather than being duplicated into every template.

### Template Namespace

The initial corpus SHALL use a domain-oriented structure:

~~~text
standards/templates/
├── README.md
├── repository/
│   └── github/
├── general/
│   └── security/
├── adr/
└── git/
~~~

This structure MAY grow when additional template families become useful.

### Distribution

Templates SHALL travel inside the same complete deterministic release archive as
the rest of the `standards/` tree.

A consuming repository that adopts a standards release therefore receives the
templates beneath its managed standards destination, normally:

~~~text
doc/standards/templates/
~~~

Receiving a template does not activate it.

### No Automatic Active Installation

Standards adoption or refresh MUST NOT automatically install, copy, generate, or
overwrite active repository files or configuration outside the managed standards
destination.

In particular, adoption MUST NOT automatically modify:

- `.github/` issue or pull-request templates;
- Git configuration;
- Git commit-template settings;
- hooks;
- workflow files;
- repository-local governance files; or
- other active repository surfaces.

A consuming repository MAY deliberately copy or adapt a released template into
an active repository location through an ordinary reviewed change.

Once copied or adapted outside the managed standards tree, that local file
belongs to the consuming repository and MAY evolve according to local governance.
It is not automatically synchronized with future standards releases.

### Examples

Templates SHOULD have parallel non-normative worked examples beneath
`standards/examples/` when a realistic completed example materially improves
understanding.

The relationship SHOULD remain obvious.  For example:

~~~text
standards/templates/general/security/stride-disclosure.md
standards/examples/general/security/stride-disclosure.md
~~~

Worked examples SHOULD show realistic completed visible content and generally
SHOULD NOT retain the instructional HTML comments from the template.

### GitHub Templates

GitHub pull-request and issue templates MAY include the Markdown front matter or
other metadata required by GitHub when that metadata is part of the template's
intended active form.

The canonical reference copy remains beneath `standards/templates/`.  A
repository-local `.github/` copy is an adopted local derivative, not another
managed standards file.

### Commit and Merge Reference Templates

Commit-message and merge-message templates SHALL remain Markdown reference
artifacts even though Git and hosting platforms do not all consume Markdown
templates natively.

These files are intended to guide humans and automated agents.  They SHALL NOT
imply that standards adoption configures `commit.template`, Git hooks, hosting
platform settings, or merge behavior automatically.

## Initial Template Set

The initial implementation SHALL include reference templates for:

- pull requests;
- bug reports;
- feature requests;
- general issues;
- security / STRIDE disclosures;
- ADRs;
- Conventional Commit messages; and
- squash or merge messages.

Additional candidates such as risk acceptances, standalone threat-model records,
release summaries, and maintainer or agent handoffs MAY be added later when their
structure is sufficiently established.

## Alternatives Considered

### Put templates beside each governing standard

Rejected because templates are a distinct reusable artifact class.  Scattering
them across normative directories would make it harder to distinguish governance
from recommended structure and would make discovery less predictable.

### Put templates under examples

Rejected because templates and examples have different purposes.  A template is
an input structure intended to be completed; an example is a completed
illustration.

### Automatically install active templates during standards adoption

Rejected because this would violate the clean managed-snapshot boundary
established by ADR-003.  It would also create upgrade conflicts with
repository-local customization and could overwrite active repository behavior
without an independent review decision.

### Maintain active repository files as synchronized generated copies

Rejected because synchronization would create another managed surface and require
tooling to reconcile local changes.  Explicit copying and adaptation through
normal review is easier to inspect and govern.

### Use native Git commit-template files instead of Markdown

Rejected as the canonical corpus format because issue #16 establishes Markdown
with HTML comment guidance as the shared template representation, while native
Git and hosting mechanisms vary.  Markdown reference templates remain portable
to humans and automated agents.

### Make template contents normative

Rejected because structure and policy should remain separate.  The governing
standard determines what is required; a template provides a useful way to collect
or communicate that information.

## Consequences

### Positive

- Recurring project artifacts gain reusable, reviewable structures.
- Humans and coding agents can begin from a common reference instead of
  reconstructing expectations repeatedly.
- Standards, templates, and examples have explicit and non-overlapping roles.
- Template instructions remain visible while editing but disappear from rendered
  Markdown.
- The complete release archive remains the only distributed standards artifact.
- Local repository customization remains deliberate and reviewable.
- Standards adoption cannot silently overwrite active repository configuration.
- Parallel examples make intended use concrete without becoming normative.

### Negative

- The standards archive grows with another artifact class.
- Template and example pairs require maintenance when governing standards change.
- Repository-local copies may drift from newer reference templates.
- Consumers must make an explicit change when they want to adopt or refresh an
  active template.
- Some reference templates, especially Git commit and merge messages, cannot be
  installed mechanically without platform-specific behavior that this decision
  intentionally excludes.

## Compatibility and Migration

Existing consuming repositories are unaffected until they adopt a release that
contains the template corpus.

After adoption, the new files appear only beneath the existing managed standards
destination.  No active repository files or configuration change automatically.

Repositories with existing local templates may compare them with the new
references and adopt selected improvements through ordinary pull requests.
There is no requirement to replace local templates merely because reference
templates are present.

## Expected Outcome

A maintainer or coding agent can discover a recurring artifact under
`doc/standards/templates/`, understand the expected structure and completion
guidance, review a corresponding worked example where available, and deliberately
adapt the template into the consuming repository when useful.

Standards adoption remains one operation with one managed destination.  Template
activation remains a separate repository decision.

## Related Decisions

- ADR-003 governs the complete release archive and managed consumer snapshot.
- ADR-005 governs ADR acceptance and decision relationships.
- ADR-006 governs the maintained current-decision digest.
- ADR-008 governs the IDEA zero-trust security framework used by the security
  disclosure template.
