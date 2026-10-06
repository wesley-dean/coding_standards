# Architecture Decisions

This directory contains the Architecture Decision Records for the coding
standards repository.  ADRs preserve the reasoning, alternatives, consequences,
and relationships behind consequential repository decisions.

The `Current Decisions` section is a curated digest of accepted decisions that
continue to govern current work in whole or in material part.  It is intended as
an orientation layer for maintainers and coding agents, not as a replacement for
the complete ADRs.  Fully superseded decisions remain part of the historical
corpus and remain discoverable in the complete inventory below.

## Current Decisions

### ADR-003: Release Artifacts and Agent-Mediated Standards Adoption

Each release publishes one deterministic `coding_standards.tar.gz` archive and
one SHA-256 checksum, and consuming repositories adopt a concrete released
version through a normal reviewed change.  Consumers commit the materialized
`doc/standards/` tree and record verified provenance in `.codingstandardrc`
rather than installing permanent standards-fetching machinery.  Applicable
imported standards are repository governance, although presence in the complete
archive does not by itself make every language-specific standard applicable.
This decision supersedes the consumer-update mechanisms in ADR-001 and ADR-002
while retaining the complete archive and committed-snapshot model.

See
[ADR-003](ADR-003-release-artifacts-and-agent-mediated-adoption.md)
for the complete context, alternatives, and consequences.

### ADR-004: Add a JavaScript Documentation Standard Based on JSDoc

JavaScript source documentation uses JSDoc as the maintained source of truth,
with `@param {Type} name - Description.` as the canonical required-parameter
form.  The shared standard describes valid JavaScript documentation independently
of the subset currently translated by `javascript-doxygen`.  The filter project
separately governs its supported translation boundary, diagnostics, tests, and
release behavior.  TypeScript and TSDoc remain outside this decision.

See
[ADR-004](ADR-004-add-javascript-documentation-standard.md)
for the complete context, alternatives, and consequences.

### ADR-005: Standardize ADR Acceptance and Decision Summaries

Every committed ADR uses `Accepted` as its status, including ADRs prepared in a
pull request intended for merge.  Acceptance records that the repository adopted
the decision into its governed history; it does not mean the decision is still
the newest governing decision on the subject.  Supersession, replacement,
deprecation, partial supersession, and related history are recorded in narrative
sections rather than alternate status strings.  ADR-006 supersedes ADR-005's
separate `doc/decisions.md` summary requirement while leaving these acceptance
and relationship semantics in force.

See
[ADR-005](ADR-005-standardize-adr-acceptance-and-decision-summaries.md)
for the complete context, alternatives, and consequences.

### ADR-006: Use an ADR Landing Page for the Current Decision Digest

`doc/adr/README.md` is the maintained landing page for the ADR corpus and the
curated digest of decisions that continue to govern current work.  Current
decision entries generally contain three to five sentences and link to the full
ADR, while fully superseded decisions remain discoverable through the complete
inventory instead of occupying the maintained digest.  The
`<!-- adrctl-generated-footer -->` marker separates curated project knowledge
from inventory content that may be regenerated mechanically.  This model
supersedes ADR-005's requirement for a separate `doc/decisions.md` summary of
every ADR.

See
[ADR-006](ADR-006-use-adr-landing-page-for-current-decision-digest.md)
for the complete context, alternatives, and consequences.

### ADR-007: Adopt General Testing and Bats Driver Standards

The standards library defines one cross-language testing model centered on
deterministic observable behavior, canonical repository-level test entry points,
direct validation of generated artifacts, explicit failure semantics, and
maintained test code.  A Bash-specific refinement treats Bats as a black-box
process driver that may test Bash, AWK, Python, compiled tools, Doxygen, or other
command-line subjects, while preserving TAP as the canonical Bats console stream
and allowing JUnit to be generated from the same execution.  Structured reports
are disposable state beneath `test-results/`, and privileged GitHub publication
is separated from pull-request code execution so richer review feedback does not
weaken the validation trust boundary.

See
[ADR-007](ADR-007-adopt-general-testing-and-bats-driver-standards.md)
for the complete context, alternatives, and consequences.

### ADR-008: Adopt the IDEA Zero Trust Security Framework

The general standards library uses zero trust as a cross-cutting security
philosophy and IDEA as its organizing framework: Identity Management, Disclosure,
Engineering, and Architecture.  Stable SEC-* commandments provide a compact
governance surface, a semantic requirements index makes detailed governing
statements easier to discover, and a high-level review-trigger checklist helps
reviewers identify where deeper analysis is warranted without treating a checked
box as proof of a vulnerability or an unchecked box as proof of security.  The
model extends zero-trust reasoning beyond network services to externally
influenced data, local files, environment values, CLI input, generated artifacts,
automation, and agentic workflows, with trust treated as contextual rather than
Boolean.  Disclosure uses STRIDE as a familiar baseline vocabulary to reduce
reviewer onboarding cost rather than as a claim of technical superiority, while
Engineering provides taint-style source-to-sink reasoning, security testing,
cryptographic transport and provenance controls, and fail-closed implementation
guidance.

See
[ADR-008](ADR-008-adopt-idea-zero-trust-security-framework.md)
for the complete context, alternatives, and consequences.

### ADR-009: Add Reusable Reference Templates

The standards library distributes reusable Markdown templates as a distinct
non-normative artifact class alongside governing standards and completed
examples.  Template guidance lives in HTML comments, while visible Markdown
represents the structure intended to remain in a completed artifact.  Templates
travel inside the normal managed standards snapshot but are never automatically
installed into active repository locations, Git configuration, hooks, or
workflows; local adoption is a separate reviewed repository change.  Parallel
worked examples demonstrate intended use, while governing standards remain
authoritative when any derivative artifact disagrees.

See
[ADR-009](ADR-009-add-reusable-reference-templates.md)
for the complete context, alternatives, and consequences.

### ADR-010: Adopt an AI Safety Standard Focused on Model Fallibility

AI-assisted engineering treats model output as fallible and requires material
claims and consequential outcomes to be verified with appropriately independent
evidence.  Authoritative objectives, permission expansion, workflow success, and
enforceable safety rules remain outside the AI-controlled trust domain; AI may
preserve or reduce its effective authority but cannot increase it.  Deterministic
orchestration owns consequential side effects and success state, while containment
bounds aggregate rate, fan-out, value, concurrency, and reversibility so one
plausible failure cannot become unbounded harm.  The standard also treats human
attention as scarce, calls for safe workflows that remain practical under delivery
pressure, and preserves identifiable human or organizational accountability when
authority is delegated to AI.

See
[ADR-010](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md)
for the complete context, alternatives, and consequences.

### ADR-011: Adopt Conventional Branch Naming With an Agent Provenance Namespace

Development branches use purpose-oriented names aligned with the repository's
Conventional Commit vocabulary, while agent-owned work prefers the vendor-neutral
`agent/<type>/<description>` namespace.  The `ai/` and `codex/` namespaces remain
accepted compatibility routes for existing automation and historical branches,
and branch names remain routing metadata rather than proof of authorship or
authorization.  Issue numbers are not required in branch names, and automatic
issue-branch creation is no longer part of the repository's workflow.

See
[ADR-011](ADR-011-adopt-conventional-branch-naming-for-agent-work.md)
for the complete context, alternatives, and consequences.
The content above the marker below is maintained project knowledge.  The content
below it is the complete ADR inventory and may be regenerated from the corpus.
Automation that refreshes the inventory must preserve the maintained content and
must fail rather than append blindly when the marker is missing.

<!-- adrctl-generated-footer -->

## Architecture Decision Records

- [ADR-001: Distribute Standards as Profile Archives](ADR-001-profile-archive-distribution.md)
- [ADR-002: Use One Standards Archive and a Consumer Update Workflow](ADR-002-single-archive-consumer-workflow.md)
- [ADR-003: Release Artifacts and Agent-Mediated Standards Adoption](ADR-003-release-artifacts-and-agent-mediated-adoption.md)
- [ADR-004: Add a JavaScript Documentation Standard Based on JSDoc](ADR-004-add-javascript-documentation-standard.md)
- [ADR-005: Standardize ADR Acceptance and Decision Summaries](ADR-005-standardize-adr-acceptance-and-decision-summaries.md)
- [ADR-006: Use an ADR Landing Page for the Current Decision Digest](ADR-006-use-adr-landing-page-for-current-decision-digest.md)
- [ADR-007: Adopt General Testing and Bats Driver Standards](ADR-007-adopt-general-testing-and-bats-driver-standards.md)
- [ADR-008: Adopt the IDEA Zero Trust Security Framework](ADR-008-adopt-idea-zero-trust-security-framework.md)
- [ADR-009: Add Reusable Reference Templates](ADR-009-add-reusable-reference-templates.md)
- [ADR-010: Adopt an AI Safety Standard Focused on Model Fallibility](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md)
- [ADR-011: Adopt Conventional Branch Naming With an Agent Provenance Namespace](ADR-011-adopt-conventional-branch-naming-for-agent-work.md)
