# ADR-006: Use an ADR Landing Page for the Current Decision Digest

Date: 2026-09-16

## Status

Accepted

## Context

ADR-005 standardized two related practices: committed ADRs use `Accepted` as
their status, and repositories maintain `doc/decisions.md` with a generally
three-to-five-sentence summary for every ADR.  The acceptance convention remains
useful because it distinguishes whether a decision entered the repository's
governed history from whether that decision continues to govern current work.

Experience with the summary file exposed a different problem.  Requiring one
summary for every ADR makes the orientation layer grow with the complete
historical corpus.  Superseded decisions remain valuable as history, but placing
them beside currently governing decisions requires a maintainer or coding agent
to reconstruct which summaries describe present constraints before work can
begin.

The complete ADR corpus and a current-decision digest answer different
questions.  The corpus answers what decisions have existed and preserves the
reasoning, alternatives, consequences, and lineage behind those decisions.  A
current-decision digest answers what accepted architectural commitments still
constrain the project now.  Combining both purposes in one maintained summary
file weakens that distinction.

The `doc/adr/` directory is also the natural entry point for the corpus.  A
`README.md` there is rendered automatically by common repository browsers and
can provide maintained current guidance together with a complete inventory of
the ADR files that live beside it.

## Decision

Repositories that use ADRs will use `doc/adr/README.md` as the landing page for
the ADR corpus and as the maintained digest of currently governing decisions.
The separate `doc/decisions.md` summary file is no longer required and should be
removed when a repository adopts this model.

The landing page contains a maintained `Current Decisions` section.  Each
accepted decision that continues to govern the repository in whole or in
material part has a concise entry that generally contains three to five
sentences.  The entry states the current rule or commitment, preserves enough
reasoning to orient a contributor, identifies important constraints or
relationships when useful, and links directly to the complete ADR.

A fully superseded historical ADR does not require a maintained entry in
`Current Decisions`.  It remains part of the repository and remains discoverable
through the complete ADR inventory.  When an earlier ADR continues to govern in
part, its current-decision entry should describe the portion that remains
operative and identify the later ADR that refined or superseded the rest.

The landing page uses the marker:

```text
<!-- adrctl-generated-footer -->
```

to separate maintained project knowledge from the complete ADR inventory.
Everything above the marker is curated.  Everything below the marker is reserved
for the corpus inventory and may be regenerated mechanically.

Repositories using `adrctl` should generate the inventory with
`adrctl.bash generate toc`.  Other tooling may produce an equivalent complete
inventory, but regeneration must preserve the maintained content above the
marker.  Automation must fail rather than append blindly when the ownership
marker cannot be found.

Adding or materially changing an ADR requires reviewing the landing page against
the resulting current governance.  A new currently governing decision normally
adds or updates a digest entry.  A decision that fully supersedes an earlier one
normally removes the earlier decision from the current digest while preserving
both ADRs in the complete inventory.  Partial supersession requires revising the
affected digest entries so they accurately describe what continues to govern.

ADR-005 continues to govern ADR acceptance semantics.  Every committed ADR still
uses `Accepted` as its status, and supersession, replacement, deprecation,
partial supersession, and related historical relationships remain narrative
relationships rather than alternate status values.

## Alternatives Considered

### Rename `doc/decisions.md` without changing its semantics

The existing summaries could have been moved wholesale to
`doc/adr/README.md`.  That would improve discoverability, but it would preserve
the central weakness of the earlier model: historical and currently governing
decisions would still be presented as one maintained digest.  The change needs
to clarify the purpose of the summary layer rather than merely relocate it.

### Keep both `doc/decisions.md` and `doc/adr/README.md`

A separate historical summary file and current-decision landing page could
coexist.  That would duplicate navigation and create another maintained
representation that could drift from the ADR corpus.  The ADRs already preserve
the historical reasoning, and the complete inventory already provides the path
into that history.

### Continue summarizing every ADR in the landing page

This would retain ADR-005's maintenance model while improving directory-level
discoverability.  It was rejected because the digest should optimize for rapid
comprehension of current architectural commitments.  Fully superseded decisions
remain available through the complete inventory and their original records.

### Maintain only a generated ADR index

A generated list answers which ADRs exist but does not explain which decisions
currently govern or why they matter.  The curated current-decision digest is
retained because orientation requires more than file discovery.

## Consequences

### Positive

- Contributors encounter current architectural guidance at the natural entry
  point to the ADR directory.
- The maintained digest scales with the current governance surface rather than
  with the entire historical corpus.
- Fully superseded ADRs remain preserved and discoverable without competing with
  current commitments for attention.
- Humans and coding agents can begin with a smaller, higher-signal context and
  follow links into detailed ADRs when a decision is relevant.
- The maintained/generated marker gives tooling an explicit ownership boundary.
- The complete inventory and the current digest have separate, well-defined
  responsibilities.

### Negative

- Maintainers must decide whether an accepted ADR still governs in whole, in
  part, or only as history.
- A digest entry may need revision or removal when later ADRs change what
  currently governs.
- Repositories migrating from ADR-005's earlier model must classify existing
  summaries rather than mechanically move all of them.

## Compatibility and Migration

Existing ADR files, numbering, and accepted status do not change merely because
the orientation layer changes.

A repository migrating from `doc/decisions.md` should:

1. create `doc/adr/README.md`;
2. identify the accepted decisions that continue to govern in whole or in
   material part;
3. write or revise concise current-decision entries for those decisions rather
   than copying every historical summary;
4. add the `<!-- adrctl-generated-footer -->` ownership marker;
5. place a complete ADR inventory below the marker;
6. update repository-facing guidance and standards that refer to
   `doc/decisions.md`; and
7. remove `doc/decisions.md` after its useful current guidance has been
   incorporated into the landing page.

The migration must not delete or rewrite fully superseded ADRs merely because
they leave the current digest.  They remain accepted historical records.

Repositories using `adrctl` may regenerate the inventory after the migration.
The maintained content above the marker remains project-owned and should not be
rewritten by inventory generation.

## Expected Outcome

A contributor or coding agent opening `doc/adr/README.md` first sees a concise
statement of the architectural decisions that still constrain current work.
Following an entry leads to the complete reasoning in the governing ADR.  The
inventory below the generated-content marker exposes every ADR, including fully
superseded historical records, without requiring those records to remain in the
maintained current-decision digest.

## Relationship to Prior ADRs

This ADR partially supersedes
[ADR-005: Standardize ADR Acceptance and Decision Summaries](ADR-005-standardize-adr-acceptance-and-decision-summaries.md).
ADR-005's `Accepted` status convention and its requirement to express decision
relationships narratively remain in force.  This ADR supersedes ADR-005's
requirement to maintain `doc/decisions.md` and its requirement that every ADR
receive a maintained three-to-five-sentence summary.
