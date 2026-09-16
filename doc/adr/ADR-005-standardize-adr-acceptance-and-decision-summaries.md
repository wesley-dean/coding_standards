# ADR-005: Standardize ADR Acceptance and Decision Summaries

Date: 2026-09-15

## Status

Accepted

## Context

Repositories in this project family already use Architecture Decision Records to capture consequential engineering and governance decisions, but their status conventions are not fully consistent.  Some ADRs use `Accepted`, some retain `Proposed`, and some encode later history directly in the status field with values such as `Superseded by ADR-...` or compound forms such as `Accepted; partially superseded by ADR-...`.

That inconsistency creates unnecessary ambiguity for both human reviewers and coding agents.  A status field can otherwise be misread as a statement about whether the ADR was ever accepted, whether it is currently the newest decision, or whether another procedural step is required after the pull request merges.

The repositories also commonly maintain `doc/decisions.md`, but the depth and maintenance expectations of those summaries have not previously been stated as shared governance.  A concise decision index is especially valuable to agents and maintainers because it provides a navigable overview before they read the full ADRs relevant to a task.

## Decision

All committed ADRs use `Accepted` as their status.

For ADRs prepared as part of work intended for merge, the ADR is written with status `Accepted` while the pull request is under review.  Merging the pull request is generally understood to accept the ADR, so a separate post-merge edit from `Proposed` to `Accepted` is not required.

Supersession, replacement, deprecation, partial supersession, and other historical relationships are expressed in the ADR narrative rather than encoded as alternate status values.  Historical ADRs remain accepted records of decisions that were valid at the time they were made even when later accepted decisions change what currently governs.

Repositories that use ADRs maintain `doc/decisions.md`.  Each ADR has a corresponding summary of generally three to five sentences that provides context, states the decision, identifies material consequences or constraints, and notes important relationships to other ADRs.  Each summary includes a direct reference to the ADR.

Adding or materially changing an ADR requires reviewing and updating the corresponding `doc/decisions.md` summary in the same pull request.  A new ADR that supersedes or refines an earlier ADR also requires updating the earlier decision summary when its current interpretation changes.

These requirements are published as the reusable Architecture Decision Record standard under `standards/adr/adr-standard.md`.

## Alternatives Considered

### Preserve multiple ADR status values

The repositories could retain states such as `Proposed`, `Accepted`, `Superseded`, and `Deprecated`.  That model can work when ADRs have a separate formal lifecycle, but it creates an additional state transition after merge and mixes two different concepts: whether a decision was accepted and whether it remains the latest governing decision.  The project does not need that additional lifecycle machinery.

### Keep supersession in the status field

The status field could continue to say `Superseded by ADR-...`.  This makes the current relationship visible, but it erases the distinction between an ADR that was never accepted and one that was accepted and later replaced.  Decision lineage belongs in the ADR narrative and the decision summary, where it can be described more precisely.

### Use `doc/decisions.md` only as a title index

A one-line index would be cheaper to maintain, but it would provide too little context to orient a reviewer or coding agent.  Three to five sentences is enough to communicate why a decision exists and what it governs without duplicating the full ADR.

### Eliminate `doc/decisions.md`

Readers could navigate ADRs directly, but that requires scanning many files to reconstruct the current decision landscape.  The summary file is intentionally retained as a maintained orientation layer over the complete ADR history.

## Consequences

The ADR status field becomes mechanically predictable and semantically narrow: `Accepted` means the repository accepted the decision into its historical record.

Superseded decisions remain visible and accepted as history, while their relationship to newer decisions is preserved in narrative sections and decision summaries.  Tools no longer need to interpret a growing vocabulary of status strings to decide whether an ADR was accepted.

Pull requests that introduce ADRs can be reviewed as complete units.  If the pull request is merged, the ADR is accepted; if the decision is not accepted, the pull request should remain unmerged, be revised, or be closed.

Maintainers and coding agents gain a stronger obligation to keep `doc/decisions.md` synchronized with the ADR set.  This adds a small documentation cost to ADR changes in exchange for substantially better inspectability and onboarding.

Existing repositories adopting this convention need a one-time normalization pass over ADR statuses and should verify that their decision summaries remain useful and linked.

## Compatibility and Migration

Existing ADR filenames, numbering, and decision content do not change merely because their status is normalized.  Historical relationships currently encoded in status text must be retained elsewhere in the ADR narrative or in the corresponding decision summary before the status is changed to `Accepted`.

Existing repositories may adopt this rule in the same pull request as other governance maintenance.  No runtime behavior, public API, or release artifact interface is affected.

ADR templates and contributor guidance that suggest alternate status values should be updated when encountered so new ADRs do not reintroduce the old lifecycle model.

## Relationship to Prior ADRs

This decision does not supersede ADR-001 through ADR-004 as historical decisions.  ADR-001 and ADR-002 remain accepted decisions whose distribution approaches were later superseded by subsequent accepted ADRs.  Their status fields are normalized to `Accepted`, while their supersession relationships remain documented in their narrative and in `doc/decisions.md`.

## Superseded By

[ADR-006: Use an ADR Landing Page for the Current Decision Digest](ADR-006-use-adr-landing-page-for-current-decision-digest.md)
partially supersedes this decision.  ADR-005 continues to govern the `Accepted`
status convention and the requirement to express supersession and related history
in ADR narrative.  ADR-006 supersedes the requirement to maintain
`doc/decisions.md` and the requirement that every ADR receive a maintained
three-to-five-sentence summary.
