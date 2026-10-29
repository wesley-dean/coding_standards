# ADR-015: Clarify Story, Task, Pull Request, and Progress Contracts

Date: 2026-10-28

## Status

Accepted

## Context

The opt-in three-phase development profile in ADR-013 separates product
planning, technical planning, and development.  ADR-014 makes each GitHub
issue's live `approved` label the authoritative approval record.  Both
decisions remain in force.

Experience planning and delivering the Certbotbot project exposed several
remaining ambiguities.  A technical task could span several pull requests,
making the task backlog a poor measure of completed delivery.  Long runs of
merged PRs obscured how many tasks remained within a story or milestone.
Tasks sometimes lacked enough context for a contributor unfamiliar with the
project to understand why the work mattered.  Finally, technical-task
completion could be mistaken for independently verified story acceptance.

A reusable planning profile must serve junior human developers and AI agents
without depending on institutional memory, prior chat history, or an assumed
ability to infer unspecified architectural decisions.  It must also preserve
the distinction among authorization, execution, and acceptance.

This decision refines the *opt-in* three-phase profile; it does not make
three-phase governance mandatory for existing consumers.

## Decision Drivers

- Make one technical task a coherent, reasonably sized review unit.
- Provide enough task purpose, constraints, and references for a junior
  developer or a new agent to execute it without reconstructing prior chats.
- Keep completed-versus-remaining counts deterministic and understandable.
- Avoid confusing an approved task with a completed or accepted capability.
- Preserve one live approval indicator and separate human approval roles.
- Offer a Kanban view without requiring GitHub Projects or custom automation.
- Keep milestone organization useful without introducing a parallel feature
  layer, deadline commitment, or overlapping progress counts.
- Maintain compatibility with existing ADR, security, testing, and PR gates.

## Decision

### Terminology and grouping

For the opt-in GitHub workflow, *issue* and *ticket* are synonymous.  Both
may identify a user story or a technical task.  *Feature* and *milestone*
are synonymous in the planning vocabulary; each refers to one GitHub
milestone containing related user stories.  A feature number and milestone
number are therefore the same identifier, not two linked hierarchies.
Milestones are logical delivery groupings, not inherently deadlines.

When three or more closely related user stories are ungrouped, they SHALL
be assigned to one suitable feature/milestone.  If no suitable milestone
exists, one SHALL be created.  Relatedness is based on a shared capability,
outcome, or deliverable rather than incidental code proximity.  One or two
stories MAY remain ungrouped.  Existing suitable milestones SHOULD be used
instead of creating redundant containers.  Story issues carry the
milestone; technical-task issues link to their parent story to avoid double
counting and GitHub's single-milestone limitation.

### Technical-task contract and one-to-one PR ownership

An approved technical task SHALL describe one bounded, cohesive,
independently reviewable outcome that can be implemented, verified,
reviewed, and merged through a single pull request.  The planning target
is an informed junior developer with access to the issue and referenced
repository documentation, whether implementation is actually performed
by a human or AI agent.

Each task SHALL make clear:

- the parent story or explicitly permitted standalone-maintenance reason;
- the problem, purpose, expected outcome, and relationship to the feature;
- relevant architecture, governing ADRs, constraints, interfaces,
  prerequisites, and known blockers;
- implementation guidance proportionate to decisions already made;
- included scope and material exclusions;
- independently verifiable acceptance criteria and verification evidence; and
- its implementing pull request once opened.

Instructions SHALL be specific enough to prevent unintended design
decisions without dictating incidental code details.  Task sizing SHALL
be evaluated by comprehensibility, ability to execute within approved
boundaries, cohesion, and reviewability, not an arbitrary line or time
limit.  If a task is too large or broad for one PR, it SHALL be decomposed
before execution where foreseeable.  When unforeseen complexity emerges,
the uncompleted scope SHALL be evaluated and split into separately
approved tasks where appropriate, rather than silently broadening the PR.

Each completed technical task SHALL correspond to exactly one *merged*
implementing PR, and each merged implementing PR SHALL deliver exactly
one technical task.  A PR MAY contain multiple commits and routine
corrections required for the same accepted scope.  Revisions to satisfy
review findings or fix task-related CI failures SHOULD stay in that PR.
Closed, unmerged, or abandoned PR attempts do not count as completion;
the replacement PR, if any, must be traceable.  This rule refines the
baseline guidance against splitting one task across multiple PRs.  It
does not waive required review, CI, CODEOWNERS, branch protection, or
architectural approval.

### Approval and Kanban lifecycle

A newly proposed issue begins in **Backlog**, outside the active board.
For open issues, the live `approved` label authorizes entry into
**Todo**.  Starting approved work places the issue **In Progress**.
An issue becomes **Done** only after its applicable Definition of Done.

Approval has phase-specific meaning: an approved *story* is authorized
for decomposition into technical tasks; an approved *technical task* is
ready and authorized for execution, subject to dependencies and other
existing controls.  Approval of a parent does not approve a child.
No issue body, comment, prior chat, or board column can replace the
live `approved` label.  Approval remains a decision by the responsible
human authority or an explicitly designated delegate, not by an agent
approving its own proposal.  A material scope change requires removal of
`approved` and renewed approval before changed work proceeds.

When decomposition begins on an approved story, that story is In
Progress.  When any child technical task enters In Progress, its parent
story SHALL also be represented as In Progress.  Partial task completion
does not revert a started story to Todo.  A story moves to Done only
after independent verification of its acceptance criteria, even if all
its technical tasks are Done.  Tasks closed as not planned do not count
as delivered.  Existing governance permits visible blockers without
adding a fifth Kanban state.

For GitHub's minimal implementation, `approved`, `in-progress`,
issue closure reason, type labels, issue links, and milestones are the
underlying records; a separate Projects board is optional.  Todo means
an open approved issue without `in-progress`, and In Progress means
an open approved issue with `in-progress`.  A material change during
active work pauses unauthorized execution; the historical record of
work already performed must not be erased or misrepresented.  Exact
board handling for that exception may be specified by the consumer.

### Equal-weight progress and acceptance

Following each merged technical-task PR, a progress report SHALL be
provided for the parent story (when one exists) and its feature/milestone
(when one exists).  Count each distinct technical task exactly once
and equally, regardless of PR commit count, estimated effort, or
subjective difficulty.

Each applicable level SHALL report completed, total, and remaining
technical-task counts, plus a completion percentage:

`progress = completed / total * 100`

For example, if a feature has three stories, each with two technical
tasks, after the first task's PR is merged the parent story reports
`1/2 complete, 1 remaining (50%)`, and the feature reports
`1/6 complete, 5 remaining (16.7%)`.

Counts SHALL use the currently identified, linked technical tasks;
closed-not-planned, duplicate, or superseded tasks SHALL NOT be counted
as delivered.  A change to the identified scope SHOULD be reported
as a denominator change.  Where stories have not yet been decomposed,
the percentage MUST be identified as progress against *known tasks*,
not an estimate of final feature completion.  A zero-task denominator
SHALL be reported as not yet measurable, not 100%.

Technical-task completion is not story acceptance.  Story acceptance
requires separate evidence for the story's independently testable
criteria, including genuine integration or external-service evidence
when required.  Feature acceptance requires accepted constituent
stories and any applicable feature-level criteria.  Release readiness
is assessed separately.  Equal-weight counts are backlog completion
measures, not effort, schedule, or production-readiness forecasts.

## Alternatives Considered

### Permit one task to span multiple merged PRs

Rejected because task completion then ceases to correspond predictably
to merged PRs and obscures remaining work.  Split the task into smaller,
cohesive tasks instead; multiple commits within a PR remain allowed.

### Require every task to fit a fixed time or line budget

Rejected because unfamiliarity, complexity, and risk do not track line
count or estimates consistently.  Cohesion, comprehension, and review
are more useful boundaries.

### Add separate feature objects or make milestones schedules

Rejected for this profile because the intended GitHub model already
provides a one-to-one feature/milestone container and does not require
dates.  Other project-management models may make different choices.

### Use issue comments or Projects status as approval evidence

Rejected by ADR-014: the live `approved` label is authoritative.
Kanban presentation cannot grant execution authority.

### Infer story acceptance from the last merged task PR

Rejected because successful mocked or unit testing may not satisfy
end-to-end, operational, or external-system acceptance criteria.

### Require GitHub Projects and automatic status synchronization

Rejected as a baseline requirement because ordinary GitHub metadata
can express the workflow.  Consumers may add a board or automation
without creating a competing source of truth.

## Consequences and Tradeoffs

- Task descriptions and decomposition require more planning discipline.
- Junior developers and new agents receive explicit context and
  scope boundaries rather than implicit institutional knowledge.
- A merged implementing PR normally advances the task-completion count
  by one, making updates auditable and understandable.
- Progress percentages may decrease as necessary work is discovered.
  Reporting count and denominator changes makes that behavior visible.
- Relationship links and parent status may require manual upkeep unless
  consumers choose automation; no automation is presumed to exist.
- Standalone maintenance tasks remain permitted under ADR-013.
- An In Progress issue whose approval is revoked needs a visible pause
  and an explicit local display convention.  No approval is inferred
  from its prior status.
- Product acceptance and release qualification remain distinct from
  implementation metrics.

## Compatibility and Migration

These rules extend only repositories explicitly opted into
`three_phase_development = true`.  Consuming repositories are not
silently changed; they adopt a released standards version through
their existing reviewed and pinned snapshot process under ADR-003.
The stricter task-to-PR and reporting obligations may require migration
of existing opted-in workflows and should be evaluated for release
classification before publication.

Existing multi-PR historical tasks need not be retroactively rewritten,
nor may their past completion evidence be fabricated.  On adoption,
active oversized tasks should be reviewed and decomposed where needed,
existing issue relationships should be reconciled, and the new rules
should apply prospectively.  The opt-in state, approved labels, issue
history, and existing accepted ADRs remain authoritative.

## Expected Outcomes

A contributor can reconstruct the purpose and boundaries of an
approved task from GitHub and repository documentation; a completed
technical task maps to one merged PR; and every merged task PR produces
an unweighted story/feature remaining-work report.  Separately
verified story and feature acceptance prevents implementation progress
from being mistaken for delivery of the intended capability.

## Related Decisions

- [ADR-003](ADR-003-release-artifacts-and-agent-mediated-adoption.md):
  reviewed distribution and explicit consumer adoption.
- [ADR-009](ADR-009-add-reusable-reference-templates.md):
  non-normative reference templates.
- [ADR-010](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md):
  human authority, model fallibility, and verification.
- [ADR-011](ADR-011-adopt-conventional-branch-naming-for-agent-work.md):
  agent branch naming.
- [ADR-012](ADR-012-enable-auto-merge-after-repository-review-gates.md):
  separate code review and integration requirements.
- [ADR-013](ADR-013-adopt-opt-in-three-phase-development-governance.md):
  original opt-in planning phases and work selection.
- [ADR-014](ADR-014-make-approved-issue-label-authoritative.md):
  label authority and revocation semantics.
