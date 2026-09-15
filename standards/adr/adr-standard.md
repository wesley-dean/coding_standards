# Architecture Decision Record Standard

## Status

Recommended repository governance

## Purpose

This standard defines how repositories record, accept, relate, summarize, and maintain Architecture Decision Records (ADRs).  It is intended for both human contributors and automated coding agents.

The goals are to keep decision history explicit, make acceptance semantics unambiguous, preserve supersession history without overloading the ADR status field, and maintain a concise decision index that can be reviewed before implementation work begins.

## Applicability

This standard applies to repositories that use ADRs.  It does not require a repository that has no ADR practice to introduce one unless other governing repository policy requires ADRs.

Repository-specific ADR conventions may refine this standard through accepted local governance, but deviations must be explicit rather than inferred or silently applied.

## ADR Status

Every committed ADR MUST use the status:

```text
Accepted
```

`Accepted` records that the decision entered the repository's governed decision history.  The status is not used to describe whether a decision is still the newest decision on a subject.

Statuses such as `Proposed`, `Draft`, `Superseded`, `Deprecated`, `Rejected`, or compound forms such as `Accepted; partially superseded by ADR-008` MUST NOT be used as the status of a committed ADR.

An ADR included in a pull request intended for merge SHOULD already say `Accepted`.  By project convention, merging a pull request that contains a new or materially changed ADR is generally understood to be acceptance of that ADR.  A separate post-merge status-edit pull request is neither required nor preferred.

A draft pull request may therefore contain an ADR whose status is `Accepted`: the pull request remains proposed work, while the ADR text expresses the status it will have if that pull request is accepted and merged.

## Decision Relationships and Historical State

Acceptance and current applicability are separate concepts.  An ADR can remain accepted historical governance even after another accepted ADR refines, replaces, narrows, or supersedes some or all of its decision.

Relationships among ADRs MUST be recorded in the ADR narrative rather than encoded as alternate status values.  Appropriate sections include:

```text
## Supersedes

## Superseded By

## Related Decisions

## Decision History
```

The wording should state the relationship precisely.  Partial supersession should identify which portion of the earlier decision changed when that distinction matters.

A superseded ADR MUST remain in the repository unless repository-specific governance explicitly requires another archival mechanism.  Historical ADRs remain useful for understanding why an earlier decision was reasonable under the conditions that existed when it was accepted.

## ADR Content

An ADR should be thorough enough to support later engineering review without relying on conversational history.  Where relevant, it SHOULD capture:

- the decision being made;
- why the decision is being made;
- conditions and constraints that exist at the time;
- material assumptions;
- alternatives considered;
- alternatives rejected and why;
- tradeoffs and consequences;
- expected outcomes;
- compatibility and migration implications; and
- relationships to prior ADRs.

Repositories with an established ADR template SHOULD preserve that template's structure when it captures equivalent information.

## Pull Request Acceptance

For work intended to merge, the ADR and implementation belong to the same reviewable decision boundary whenever practical.

The normal lifecycle is:

1. draft or update the ADR with status `Accepted`;
2. update the corresponding `doc/decisions.md` entry in the same change;
3. include implementation and documentation governed by that decision as appropriate;
4. review the pull request as a whole; and
5. treat merge of the pull request as acceptance of the ADR.

If reviewers do not accept the decision, the pull request should remain unmerged, be revised, or be closed.  The repository should not merge an ADR as `Proposed` with the expectation that a later mechanical status change will make the decision authoritative.

## Decision Summary Index

A repository that contains ADRs MUST maintain:

```text
doc/decisions.md
```

`doc/decisions.md` is a concise navigation and orientation layer over the complete ADR record.  It does not replace the ADRs themselves.

Each ADR MUST have a corresponding summary entry in `doc/decisions.md`.  Each entry SHOULD generally contain three to five sentences that provide enough context for a reader to understand the decision before following the ADR link.

A useful summary normally includes:

- the problem or context that caused the decision to be made;
- the decision or governing rule that resulted;
- an important consequence, constraint, or implementation implication; and
- any important relationship to a later or earlier ADR.

Each summary entry MUST include a direct reference to its governing ADR.

If an ADR is superseded, refined, narrowed, or otherwise changed by another ADR, the relevant `doc/decisions.md` summaries MUST be updated so the relationship is visible without requiring the reader to discover it accidentally.

## Maintaining `doc/decisions.md`

Adding an ADR requires adding its decision summary in the same pull request.

Materially changing an ADR requires reviewing and, when necessary, updating its decision summary in the same pull request.

Adding a new ADR that supersedes or refines an earlier ADR requires updating the summaries for both the new decision and any earlier decision whose current interpretation changed.

Agents and contributors MUST NOT treat `doc/decisions.md` as a write-once historical artifact.  It is maintained documentation of the repository's decision graph and should remain synchronized with the ADR set.

A repository-wide ADR review SHOULD verify that:

- every ADR status is `Accepted`;
- every ADR has a `doc/decisions.md` entry;
- every decision summary references its ADR;
- summaries are generally three to five sentences rather than title-only index entries;
- supersession and related-decision relationships are represented in narrative form; and
- no current guidance incorrectly depends on `Proposed`, `Superseded`, or another alternate ADR status.

## Guidance for Automated Tools and Agents

Before consequential repository work, an agent SHOULD read `doc/decisions.md` and the ADRs relevant to the requested change.

When an agent creates or materially changes an ADR, it MUST:

1. use `Accepted` as the ADR status;
2. record supersession or related-decision information in narrative sections;
3. update `doc/decisions.md` in the same change;
4. keep the summary to roughly three to five useful sentences unless additional context is genuinely necessary; and
5. include a direct reference from the summary to the ADR.

An agent MUST NOT create a follow-up pull request whose sole purpose is to change an ADR from `Proposed` to `Accepted` after the governing pull request has already been merged.

## Review Checklist

Before merging a pull request that adds or changes ADR governance, verify:

- [ ] Every affected ADR says `Accepted` under `## Status`.
- [ ] Supersession, replacement, or deprecation relationships are preserved in narrative form.
- [ ] Every new ADR has a `doc/decisions.md` summary.
- [ ] Every materially changed ADR has had its decision summary reviewed and updated where necessary.
- [ ] Each summary is generally three to five sentences and links directly to its ADR.
- [ ] Earlier summaries affected by a new superseding or refining decision have also been updated.
- [ ] The pull request is sufficient to treat merge as acceptance of every ADR it introduces or materially changes.

## Governing Principle

An ADR records an accepted decision and remains part of the repository's decision history.  Later decisions may change what governs now, but they do not erase the fact that an earlier decision was accepted.  Keep acceptance in the status field, keep evolution in the narrative, and keep `doc/decisions.md` synchronized so the decision history remains usable.