# Opt-In Three-Phase Development Governance

## Status

Optional repository governance; normative only when explicitly enabled.

## Purpose

This standard extends [Development Workflow and Backlog Governance](development-workflow-governance.md) with three phases: product planning, technical planning, and implementation.  It does not replace baseline scope control, architecture, testing, security, or PR governance.  Its purpose is to make a project's approved requirements, work, decisions, and progress reconstructible without relying on a prior conversation.

MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative when the profile is enabled.

## Activation and Compatibility

The repository root `.codingstandardrc` MAY contain:

~~~toml
three_phase_development = true
~~~

Omitted or explicitly `false` means disabled.  No repository is enrolled based on its age, template origin, or a standards upgrade.  Missing configuration means disabled; a malformed or non-Boolean value MUST be reported and MUST NOT be interpreted as authorization.  A new-project initialization SHOULD explicitly enable the profile after adopting and recording a verified standards release.  Existing repositories retain their previously selected governance unless they explicitly opt in through a reviewed change.

Standards adoption, upgrade, downgrade, and repair MUST preserve the repository's explicit workflow selection.  The optional field does not alter the existing `source`, `version`, `sha256`, or `destination` provenance fields.  An adoption process MUST NOT silently discard unrelated repository-owned configuration or fabricate provenance.

When disabled, the existing Development Workflow and Backlog Governance standard remains applicable without the additional phase, issue-label, or approval requirements below.  This profile imposes no retrospective triage requirement on an existing repository unless it opts in.

## Roles and Boundaries

A person MAY occupy several roles; an AI agent MAY assist in several roles, but role names and write access do not grant authorization.  The project MUST retain an identifiable human or explicitly designated repository authority for consequential decisions.

| Role | Responsibility | Approval boundary |
| --- | --- | --- |
| Product Owner | Defines product value, scope, epics, priorities, and acceptance criteria | Approves user stories for technical planning |
| Project Manager | Facilitates requirements, planning, story quality, and backlog visibility | May recommend, not self-approve |
| Technical Architect | Owns architecture, security boundaries, interfaces, and the technical plan | Approves technical tasks for development and consequential design choices |
| Senior Engineer | Decomposes approved stories into technical tasks, dependencies, and verification plans | May recommend, not self-approve |
| Implementer | Executes approved tasks, verifies outcomes, and proposes reviewable changes | May choose routine implementation details inside the approved contract |

Delegation of approval authority MUST be documented in repository governance.  Agents MUST NOT acquire authority simply by changing roles or starting another chat.

## Phase 1: Project Management (What and Why)

The Project Manager collaborates with the Product Owner to define product goals, scope, epics, and user stories.  Stories SHOULD follow:

> As a [role], so that [benefit], I want [capability].

Stories MUST capture desired behavior with observable acceptance criteria, relevant constraints, known dependencies, and exclusions.  They SHOULD avoid prematurely committing to a particular implementation.  Proposed stories may be created freely; their existence does not authorize technical or implementation work.

**Exit gate:** The Product Owner authorizes technical planning by applying the `approved` label to the particular user-story issue, or by explicitly directing its application.  That label is the authoritative approval state for the story's current scope and priority.  Story approval does not authorize technical tasks without their own `approved` label.

## Phase 2: Technical Planning (How)

The Senior Engineer MUST review repository governance and accepted ADRs before proposing the implementation.  Each distinct technical task SHOULD link to its parent approved story and describe implementation boundaries, dependencies, verification, compatibility requirements, and completion criteria.  Every technical task MUST be scoped as one independently reviewable pull request; oversized tasks MUST be decomposed before execution when foreseeable.  Each task MUST explain its purpose and parent feature context, intended outcome, relevant governing decisions, explicit scope exclusions, acceptance criteria, and verification evidence so an informed junior developer or a new AI agent can execute it without relying on prior conversations.  The task's detail SHOULD guide consequential decisions without dictating incidental implementation choices.  Stories SHOULD link back to their tasks.

Consequential architecture, security, persistence, public-interface, deployment, and compatibility decisions MUST follow repository ADR and approval governance.  A task issue cannot replace an ADR.

**Exit gate:** The Technical Architect authorizes a technical task for development by applying the `approved` label to that task, or by explicitly directing its application after reviewing the technical approach and required ADRs.  The task's own label is authoritative; an approved parent story does not approve its technical tasks.

## Phase 3: Development (Execute and Verify)

Before execution, an implementer MUST examine the current approved issues, governing documentation, dependencies, and blockers.  Work MUST follow the priority rules below and remain within authorized task scope.  Routine helpers, tests, documentation, error handling, and other necessary supporting work MAY be done without separate approval if they preserve the approved contract.

Implementers MUST link changes and PRs to tracked tasks, report actual verification evidence, and avoid claiming delivery merely because code has been written or merged.  One completed technical task MUST map to exactly one merged implementing PR, and each merged implementing PR MUST implement exactly one technical task.  Multiple commits and in-scope review corrections MAY remain in that PR.  Closed, unmerged attempts do not count as completion.  After each task PR merges, provide equal-weight story and feature progress counts as specified below.

**Exit gate:** A technical task is Done only after its own Definition of Done; a story is Done only when its acceptance criteria have been independently verified.  Release readiness is assessed separately.  Separate chats MAY represent these phases, but the repository and approval records remain authoritative.

## Issue and Milestone Conventions

When using GitHub, the profile SHOULD use ordinary issues, labels, milestone fields, and Markdown links; no GitHub Projects board or custom issue-management tooling is required.  Repositories using another tracker MUST document equivalent, inspectable controls.

The suggested GitHub labels are:

| Label | Meaning |
| --- | --- |
| `type:story` | A product/user requirement |
| `type:task` | An implementation task |
| `approved` | Authoritative, sufficient approval of this issue's current scope for its phase |
| `in-progress` | Work underway on an open issue |
| `priority:high` | High priority |
| `priority:low` | Low priority |

Neither priority label means normal priority.  The two priority labels MUST NOT coexist, and each issue SHOULD have one type label.  For an **open** issue, `approved` without `in-progress` means TODO; `approved` plus `in-progress` means In Progress.  An open issue without `approved` is **proposed**, not TODO, regardless of any other labels.  Closure with reason completed means Done only after the applicable Definition of Done; issues closed as not planned are excluded from delivered work.

For this GitHub profile, *feature* and *milestone* are interchangeable names for the same GitHub milestone; *issue* and *ticket* are interchangeable names for a GitHub issue.  When three or more closely related ungrouped stories share a common outcome, they MUST be assigned to an existing suitable feature/milestone or a newly created one.  One or two stories MAY remain ungrouped.  A milestone is not inherently a delivery-date commitment.

Every story **and technical-task issue** associated with a feature MUST be assigned directly to its GitHub milestone.  Each child task MUST additionally link to its parent story and MUST use the same milestone as that story; a standalone maintenance task MAY be assigned to an applicable feature directly.  An issue with no associated feature need not have a milestone until grouped.  **Implementing PRs MUST NOT be assigned to feature/milestones**; they link to their technical tasks.  An issue has only one GitHub milestone; cross-cutting relationships use issue references.  Story checklists with issue links remain navigation aids rather than automatically authoritative task counts.  Blockers MUST be recorded visibly.  Periodic backlog audits SHOULD identify missing or inconsistent story/task milestone assignments and unintended PR milestone assignments.

The native GitHub milestone percentage consequently measures combined **issue closure** across directly assigned stories and tasks, rather than story acceptance or task-only implementation.  It can also count issues closed as not planned.  Use separate, clearly named story-acceptance and equal-weight technical-task metrics for delivery reporting; a 50% story-acceptance rate need not produce a 50% native milestone closure percentage.

The Kanban lifecycle is Backlog (unapproved proposals outside the active board), Todo (open, approved, not yet started), In Progress (approved and started), and Done (verified completion).  Story approval authorizes technical decomposition; task approval authorizes execution.  When decomposition starts on a story, or a child task starts, the story MUST be In Progress; partial completion does not return a started story to Todo.  A story moves to Done only after its independent acceptance criteria are verified, not merely when its final task PR merges.  Approval removal due to material scope change MUST suspend further affected execution; historical work already performed must not be misrepresented as never started.  A consumer MAY show a blocked or paused condition without inventing a fifth Kanban status.

Label creation is a one-time repository setup step where needed.  Reference templates are distributed with the standards but are not activated automatically.

## Authoritative Approval Labels and Scope Changes

For an opted-in repository using GitHub, the presence of the `approved` label
on an issue is the **authoritative and sufficient workflow approval record** for
that issue's current scope and phase.  On a `type:story` issue it signifies
Product Owner authorization for technical planning.  On a `type:task` issue
it signifies Technical Architect authorization for development, including the
bounded maintenance path.  Absence of the label means the issue is not approved,
regardless of its title, milestone, issue text, or parent status.

An additional issue comment, dated approval statement, audit of who applied the
label, or separately maintained approval section is **not required** to establish
that workflow approval.  Agents and contributors selecting work MUST use the
issue's current live label state instead of reconstructing approval from comments
or cached summaries.  Approval applies only to the labeled issue; it does not
flow automatically from a labeled story to its technical tasks or across phases.

The decision to approve MUST originate with the human responsible for the
appropriate project role, or an explicitly designated repository authority.
That person MAY apply the label directly or explicitly instruct an agent or
tool to apply it to identified issues.  Agents MUST NOT decide to approve their
own proposals, add the label without such a direction, infer approval from
silence, or broaden an approval to other issues.  Repositories SHOULD limit
label modification to trusted actors through their available governance and
permissions.  The label represents workflow approval, **not** GitHub access
control, permission escalation, a substitute for accepted ADRs, or PR review
and merge authorization.

A materially changed approved issue MUST have `approved` removed and must
receive a new approval decision before the changed scope becomes actionable.
This includes changed acceptance criteria, new independently valuable behavior,
material interface or compatibility changes, or consequential security or
architecture decisions.  Routine implementation detail within the approved
contract does not require removing the label.  An agent MAY remove the label to
prevent work on materially changed scope but MUST NOT restore it autonomously.

Immediately before beginning consequential implementation, the implementer
SHOULD re-read the issue's current labels and check applicable dependencies,
ADRs, and blockers rather than relying on a prior snapshot.  This policy
changes issue-level workflow authorization evidence only; all independent
security, testing, human accountability, and repository review controls remain.

## Newly Discovered Work and Blockers

Agents MAY discover and create additional issue proposals during development.  The default is **unapproved**.

- Necessary supporting work within an approved task MAY proceed normally.
- Distinct additional engineering work for an existing approved story SHOULD become an unapproved technical task for Technical Architect review.
- New product functionality or materially changed story requirements MUST become an unapproved story for Product Owner review.
- Consequential design decisions require the applicable architectural review/ADR.
- Vulnerabilities or sensitive details MUST follow private security reporting rather than public issue creation.

If new work blocks an active task, document the blocker and related proposal or decision, stop only affected work, and proceed to another approved actionable task if possible.  An affected task MAY remain `in-progress` while visibly blocked.  An agent MUST NOT silently reprioritize its proposals or implement them to avoid waiting for approval.

## Definitions of Ready and Done

**Story Ready:** Desired behavior, acceptance criteria, scope boundaries, priority, and dependencies are identifiable, and the story bears the authoritative `approved` label.

**Task Ready:** The task bears its own authoritative `approved` label, its parent story is approved (or the maintenance exception below applies), and agreed technical scope, governing ADRs, dependencies, and a verification plan are recorded.

**Task Done:** The authorized implementation and necessary tests/documentation are complete; relevant checks have passed or their limitations are explicitly documented; and its single implementing PR has been reviewed and merged through required gates.  A task closed without delivery (duplicate, obsolete, or not planned) is not Done.

**Story Done:** Required technical work is completed and its independently verifiable acceptance criteria have been shown to pass.  Closing the final task or merging a PR is not by itself acceptance of the story.

For the opt-in profile, use non-closing PR references such as `Refs #123` until issue closure conditions are satisfied.  A closing keyword MAY be used only when merging itself fulfills the Definition of Done and `in-progress` cleanup is handled.  Closing a completed issue SHOULD remove `in-progress`.  A declined issue MUST NOT be counted as delivered.

### Lightweight Maintenance Path

A bounded defect correction, documentation fix, or routine maintenance operation MAY be approved and executed as a stand-alone technical task without a parent story, provided its own `approved` label is applied under the Technical Architect's authority and it introduces no new product behavior or consequential architecture.  It still needs traceable scope, workflow approval, verification, and completion.  This is not a loophole to relabel features as maintenance.  Urgent security work follows the repository's secure escalation procedures.

## Work Selection and Priority

Unless the authorized human reprioritizes work, implementers SHALL:

1. Finish actionable open, approved `in-progress` technical tasks first.
2. Then select approved TODO tasks marked `priority:high`.
3. Then select approved TODO tasks with normal (unlabeled) priority.
4. Finally select approved TODO tasks marked `priority:low`.
5. Within each tier prefer the oldest actionable task by issue creation time.

Dependencies and blockers take precedence.  Product stories are not execution-queue items.  Prefer one active task per agent unless parallel effort has an explicit benefit.  Add `in-progress` when starting an approved task; remove it and close the task with the completed reason only after verification.

## Reporting, Handoffs, and Migration

After each merged technical-task PR, report completed, total, and remaining technical tasks for its parent story and feature/milestone, with equal weight per distinct technical task and a percentage calculated as completed/total * 100.  Do not use the combined native GitHub milestone closure count as the denominator for the task-only measure.  A feature with three stories of two tasks each reports 1/2 completed and 1 remaining (50%) for its first story and 1/6 completed and 5 remaining (16.7%) for the feature after the first task merges.  Use the current identified task count, disclose additions or removals that change the denominator, and count closed-not-planned work as neither delivered nor remaining.  If stories have not been fully decomposed, label the result provisional progress against *known* tasks; zero identified tasks means progress is not yet measurable, not 100%.

Reports SHOULD separately show completed versus approved technical tasks, accepted versus approved stories, and accepted stories within each epic.  Include both counts and percentages, explicitly exclude rejected/not-planned work from delivered counts, and disclose any additions or removals from approved scope.  Unweighted issue counts are **not** a measure of effort, delivery date, or production readiness.

A handoff SHOULD leave enough durable issue/repository context to reconstruct current approval labels, blockers, verification results, accepted decisions, and the next actionable task without access to prior chats.

New-project setup SHOULD set `three_phase_development = true` only after recording actual released standards provenance.  Existing repositories opting in SHOULD inventory their current backlog and apply `approved` only to work authorized by the appropriate human; no preexisting issue is automatically authorized.  Opting out does not waive baseline engineering, security, or review governance.

## Related Standards and Templates

- [Development Workflow and Backlog Governance](development-workflow-governance.md)
- [AI Safety Standard](ai/safety-standard.md)
- [User Story](../templates/repository/github/user-story.md)
- [Technical Task](../templates/repository/github/technical-task.md)
