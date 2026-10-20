# ADR-013: Adopt Opt-In Three-Phase Development Governance

Date: 2026-10-19

## Status

Accepted

## Context

Agent-assisted development can drift beyond approved scope when desirable but unplanned work is implemented during an existing task.  That obscures progress against a product plan and makes it hard for a new developer or agent to reconstruct what is authorized.  The existing Development Workflow and Backlog Governance standard already requires surgical changes, independent backlog capture, and reviewable pull requests, but it does not define a complete product-to-engineering planning lifecycle, explicit approval of proposed tasks, or a shared issue status vocabulary.

Repositories vary: existing consumers must not acquire a new mandatory planning regime simply by refreshing standards.  New repositories should be able to select stronger discipline intentionally.  GitHub's issue, label, and milestone facilities suffice; maintaining custom automation or a Projects board would add unnecessary moving parts.

Existing ADR-003 establishes the released standards archive, consumer provenance, and the root `.codingstandardrc` contract.  ADR-009 governs non-normative reference templates.  ADR-010 distinguishes human authorization from agent capabilities, recommendations, and mutable metadata.  ADR-011 and ADR-012 govern related branch and pull-request behavior.

## Decision Drivers

- Make approved scope, engineering work, and progress recoverable from durable repository state.
- Separate product authority from technical implementation authority.
- Permit agents to discover and propose new work without self-authorizing it.
- Preserve existing consumer behavior and released standards adoption semantics.
- Support small teams without creating separate project-management software.
- Keep routine implementation and bounded maintenance practical.
- Maintain explicit verification, architectural governance, and review gates.

## Decision

The standards library SHALL add `standards/general/three-phase-development-governance.md` as an optional extension to the existing Development Workflow and Backlog Governance standard.

A repository SHALL opt in only by explicitly setting the optional root `.codingstandardrc` Boolean:

~~~toml
three_phase_development = true
~~~

An absent field or `false` SHALL mean disabled.  Existing consumers SHALL remain disabled unless they intentionally opt in.  New-project initialization SHOULD explicitly enable the option once actual standards release provenance is recorded.  No agent SHALL infer an opt-in from repository age or the presence of a standards release.

The optional field extends the configuration model governed by ADR-003 without modifying `source`, `version`, `sha256`, or `destination`.  Adoption, refresh, upgrades, downgrades, and repairs SHALL preserve the explicit repository selection and SHALL NOT silently activate the new profile.  Configuration that cannot be interpreted as a Boolean is invalid and cannot establish enrollment.  A new-project initializer may set the default to `true` for newly created repositories without rewriting the configuration of existing repositories.

When enabled, the workflow defines three phases:

1. **Project Management:** A Project Manager assists the Product Owner in preparing product-oriented user stories, acceptance criteria, epic grouping, and priority.  Product Owner approval authorizes a story for technical planning.
2. **Technical Planning:** A Senior Engineer assists the Technical Architect with decomposition into technical tasks, dependencies, verification requirements, and applicable ADRs.  Technical Architect approval authorizes technical tasks for development.
3. **Development:** Implementers select authorized actionable tasks in defined priority order, execute bounded work, obtain review, and verify task completion and story acceptance separately.

Approval SHALL be attributable, explicit, and scoped to the issue and phase; it SHOULD be recorded through GitHub issue comments.  Proposed issues remain unapproved by default.  The `approved` label is a selection aid rather than an authentication or access-control mechanism.  A material change to approved scope requires renewed authorization.  Necessary supporting work within the original contract remains ordinary implementation discretion.  A bounded maintenance task may bypass the story phase only with explicit technical approval.

GitHub implementations SHOULD use milestone-as-epic grouping, bidirectionally linked story/task issues, and a small label set: `approved`, `in-progress`, `priority:high`, `priority:low`, `type:story`, and `type:task`.  Open approved work without `in-progress` is TODO; approved open work with `in-progress` is underway; verified closed-completed work is Done.  Work selection privileges actionable in-progress tasks, then high, normal, and low priority TODO tasks, with older actionable tasks preferred within each tier.  The same principles may be implemented in other trackers without imposing GitHub as a universal dependency.

The library SHALL add non-normative user-story and technical-task templates under `standards/templates/repository/github/`.  Publishing reference templates SHALL NOT install them as active issue templates in consumer repositories.

When the profile is disabled, the preexisting Development Workflow and Backlog Governance policy retains its existing scope and semantics.  The profile does not waive security, testing, accepted ADRs, or pull-request governance.

## Alternatives Considered

### Make three phases universally mandatory

Rejected because existing consumers would incur new planning and approval obligations when updating otherwise compatible standards.

### Use GitHub Projects with a Kanban board

Rejected for the baseline design: its administration adds another state representation, while issues, labels, and milestones cover the required traceability with less overhead.

### Implement custom project-management automation

Rejected because bespoke tooling creates a maintenance and authorization surface disproportionate to the needs of these projects.

### Treat every open issue as approved

Rejected because agents must be able to record unapproved discoveries without granting themselves permission to implement them.

### Rely on a verbal instruction or individual chat history

Rejected because conversations may be truncated, restarted, or handed to another implementer.  The project state and approval record must be durable and inspectable.

### Require formal story planning for every maintenance change

Rejected because narrow maintenance can be appropriately authorized as a technical task without inventing product stories.

### Use milestones for both releases and overlapping feature hierarchies

Not chosen for this profile.  Milestones serve mutually exclusive epic groupings; overlapping feature links remain ordinary issue references.

## Consequences

### Positive

- Human product and technical authority remain distinct from agent suggestions and repository write capability.
- New discoveries become visible proposals rather than untracked implementation scope.
- A new agent can select work from recorded issues and repository governance.
- Existing repositories retain their present process without migration.
- No GitHub Projects board, workflow service, or custom issue-management tooling is required.
- Separate measures of engineering completion, accepted product behavior, and release readiness become possible.

### Negative

- Human review, issue maintenance, and approval comments require additional effort in opted-in repositories.
- Mutable labels cannot enforce authorization and must be checked against approval evidence.
- Markdown issue links and checklists require upkeep and do not provide automatic parent/child synchronization.
- Each GitHub issue has only one milestone, limiting overlapping epic representation.
- Existing strict configuration parsers may need compatibility verification before they accept the new optional key.

## Compatibility and Migration

This is a backward-compatible opt-in feature, intended for a minor version release under the Conventional Commit release standard.  Existing valid configurations without the field remain valid and retain their workflow.  Standards upgrade operations preserve the explicit setting.

An existing repository choosing to opt in should review its backlog, record approval authority, establish label conventions, and obtain approvals for work entering development.  Previously created or open issues do not become approved automatically.  New-project setup should explicitly record `true` but must still obtain and verify real release provenance; no version or checksum may be fabricated.

The new field is configuration data, not an execution hook.  This decision does not introduce a runtime parser, approval service, or permissions enforcement.  If a consumer's existing tooling strictly rejects unknown fields, that tooling must be updated or the opt-in deferred; compatibility is not assumed without testing.

## Expected Outcome

Future planned projects can start with explicit product and technical planning gates while existing repositories remain unaffected.  Human approval is visible, out-of-scope discoveries do not silently enter execution, and progress can be evaluated against the approved backlog rather than incidental implementation activity.

## Related Decisions

- [ADR-003](ADR-003-release-artifacts-and-agent-mediated-adoption.md): released standards provenance and adoption.
- [ADR-009](ADR-009-add-reusable-reference-templates.md): non-normative templates.
- [ADR-010](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md): AI authority, verification, and boundaries.
- [ADR-011](ADR-011-adopt-conventional-branch-naming-for-agent-work.md): agent branch naming.
- [ADR-012](ADR-012-enable-auto-merge-after-repository-review-gates.md): integration approval boundaries.
