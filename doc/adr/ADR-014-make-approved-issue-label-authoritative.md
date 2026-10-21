# ADR-014: Make the Approved Issue Label Authoritative

Date: 2026-10-20

## Status

Accepted

## Context

The optional three-phase workflow established by ADR-013 separates Product Owner
authorization of user stories from Technical Architect authorization of engineering
tasks.  Its original rule treated GitHub's `approved` label as a navigation aid
and required an additional attributable issue comment or equivalent approval
record.  The reference story and task templates reinforced that requirement with
an `Authorization` section.

This duplicates state: the issue may carry `approved` while its text still says
"proposed" or "unapproved", requiring an implementer to investigate historical
comments before trusting the current task queue.  Separate prose and comments
can become stale when issues change.  A repository already using GitHub issue
labels for status needs a single inspectable current approval indicator.

ADR-010 and the AI safety standard prohibit an AI agent from authorizing itself,
expanding its own authority, or silently modifying its success criteria.  The
proposed label rule is workflow authorization state, not a grant of platform
permissions or the ability to circumvent security and review requirements.
Making mutable labels authoritative accepts a risk that repositories must manage.

## Decision Drivers

- Make one current GitHub issue field sufficient to determine approval for each
  planning or development phase.
- Eliminate contradictory approval prose and repeated comment inspections.
- Preserve the distinction between story and technical-task authorization.
- Retain human accountability and prevent agent self-approval.
- Keep material scope changes from silently inheriting prior authorization.
- Preserve security, accepted ADR, CI, and PR-review boundaries.
- Avoid custom automation or a GitHub Projects dependency.

## Decision

In a repository that has opted into `three_phase_development = true`, the
presence of the `approved` label on a particular GitHub issue SHALL be the
**authoritative and sufficient workflow approval record** for the issue's
current scope.  For a `type:story` issue, the label authorizes technical
planning under the Product Owner's authority.  For a `type:task` issue, the
label authorizes implementation under the Technical Architect's authority.
An open issue without `approved` is not authorized for the next phase.
Approval of a story SHALL NOT implicitly approve any of its technical tasks.

An issue comment, separate `Authorization` section, date-stamped approval
statement, or independent audit of the label's authorship SHALL NOT be an
additional prerequisite for planning or task selection.  The current live
label state SHALL be read instead of relying on cached state, issue prose,
or prior conversation.  Reference user-story and technical-task templates
SHALL omit instructions or headings demanding separate approval records.

A human with the appropriate role, or an explicitly designated repository
authority, SHALL make each approval decision.  The person MAY apply
`approved` directly or explicitly instruct an agent/tool to apply it to
specific issues.  Agents SHALL NOT independently approve their own proposals,
infer approval from silence or issue creation, or extend one approval to other
issues.  Repositories SHOULD constrain issue-label modification to trusted
actors through available permission/governance mechanisms.

Material changes to an approved issue's product scope, architecture, interface,
security or compatibility contract SHALL cause `approved` to be removed.
The label may return only after a renewed decision by the appropriate human
authority.  Agents MAY remove approval when material drift is discovered,
but SHALL NOT restore it without express direction.  Ordinary details
within an unchanged authorized scope do not trigger this rule.

The label governs **work selection and issue phase only**.  It does not grant
GitHub permissions, establish a cryptographic identity claim, supersede accepted
ADRs, waive security or testing controls, or authorize pull-request review and
merge.  PR review, repository rulesets, CODEOWNERS, and CI remain independent.
Equivalent non-GitHub trackers MAY provide an equally authoritative approval
field if explicitly documented.

This decision partially supersedes ADR-013's requirement for separate approval
comments or author-verified records and its description of `approved` as merely
an indexing aid.  It retains ADR-013's opt-in configuration, role separation,
story/task phases, milestone and priority conventions, and completion gates.

## Alternatives Considered

### Keep the label as an indexing aid backed by comments

Rejected for this workflow because it requires maintaining and interpreting
two mutable representations of the same current approval state.  Stale issue
bodies and absent comments make the task queue difficult to use reliably.

### Require human issue comments plus the label

Rejected because two approvals or two proof locations add operational
friction and leave unresolved disputes when they disagree.

### Let any agent apply approval whenever it judges a task ready

Rejected because it makes proposal authors capable of granting themselves
authority and conflicts with ADR-010 and the AI safety standard.

### Make labels grant GitHub permissions or bypass PR review

Rejected because an issue label is mutable project metadata, not a
GitHub access-control mechanism.  Repository controls and reviews remain
necessary independently of development planning.

### Add a dedicated approval service or GitHub Projects board

Rejected because the requested change is a simpler workflow convention
over existing ordinary issues and labels.

## Consequences

### Positive

- One live GitHub field identifies each issue's approval state.
- Issue descriptions and reference templates no longer accumulate contradictory
  `Authorization` prose.
- Agents can select eligible work without reconstructing issue-comment history.
- The Product Owner/Technical Architect distinction and independent PR review
  requirements remain intact.
- Disabling three-phase governance still preserves the baseline workflow.

### Negative

- Anyone who can change trusted issue labels can potentially alter the
  effective work queue.  This is an accepted governance and trust-boundary
  tradeoff, not an assertion that labels authenticate the decision-maker.
- GitHub may not offer fine-grained control over a particular label in every
  repository; projects must account for the actual permissions of their agents.
- Historical comments no longer provide a required parallel audit trail for
  approval decisions.
- Material changes require disciplined removal and subsequent reapplication
  of the label so that approval is not silently carried forward.

## Compatibility and Migration

The opt-in field in `.codingstandardrc` and the set of standard label names
remain unchanged.  This is a substantive change in authorization semantics
for repositories already opting into the three-phase workflow, so it merits
breaking-change treatment under the repository's semantic-release governance.
Existing consumer standards remain pinned until a released version containing
this decision is explicitly adopted; the PR does not rewrite those snapshots.

On adoption, an opted-in repository should ensure that its existing `approved`
labels reflect decisions by the appropriate human roles, remove stale or
misleading approval prose from issue bodies, and update its active issue
templates if installed separately.  Nothing automatically marks previously
unlabeled work approved.  Agents should refresh labels at task-selection time
and should not infer authorizations from legacy comments.

## Expected Outcome

An agent entering an opted-in repository can determine story and technical-task
approval by inspecting each issue's current `approved` label while still
honoring dependencies, ADRs, human role boundaries, security policy, and
separate review and merge gates.

## Related Decisions

- [ADR-013](ADR-013-adopt-opt-in-three-phase-development-governance.md):
  partially superseded as to approval evidence and label semantics.
- [ADR-010](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md):
  human authority and independent control of consequential decisions.
- [ADR-009](ADR-009-add-reusable-reference-templates.md):
  reusable, non-normative issue-template structure.
- [ADR-011](ADR-011-adopt-conventional-branch-naming-for-agent-work.md):
  agent branch naming and provenance cues.
- [ADR-012](ADR-012-enable-auto-merge-after-repository-review-gates.md):
  PR review and merge remain independent authorization boundaries.
