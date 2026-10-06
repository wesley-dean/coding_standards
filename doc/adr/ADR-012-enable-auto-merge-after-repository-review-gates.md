# ADR-012: Enable Auto-Merge After Repository Review Gates

Date: 2026-10-05

## Status

Accepted

## Context

The Development Workflow and Backlog Governance standard treats a pull request's
transition from Draft to Ready for review as an explicit declaration that the work
is complete for its intended scope and may be merged once normal repository gates
are satisfied.

Repositories commonly enforce those gates through hosting-platform controls such
as required CI checks, branch protection, rulesets, required reviews, and
CODEOWNERS approval.  When those controls are authoritative, a separate manual
merge action after every gate has already succeeded does not add an independent
review decision.  It repeats the mechanical act of completing the merge.

Automated coding agents can often enable the hosting platform's auto-merge
facility when they create or finish a pull request.  Auto-merge can reduce
unnecessary coordination while preserving a human approval boundary, provided
the platform continues to enforce all repository requirements before merge.

This distinction is particularly important for agent-assisted development.  An
agent enabling auto-merge must not be interpreted as approving its own work,
waiving review, expanding its authority, or replacing a required human decision.
The hosting platform remains the deterministic mediator of the final transition,
and repository gates remain authoritative.

## Decision Drivers

- Preserve required human review as an authorization boundary.
- Avoid requiring a second manual action when all intended merge gates have
  already succeeded.
- Make agent behavior predictable across repositories that adopt the shared
  development workflow.
- Keep Draft and Ready-for-review states meaningful.
- Preserve branch protection, rulesets, CI, CODEOWNERS review, security review,
  and repository-specific merge requirements.
- Avoid allowing an automated agent to convert unresolved decisions into an
  automatic merge.
- Preserve the repository's chosen merge strategy and reviewed release
  classification.
- Keep the behavior compatible with the zero-trust and AI-safety requirements
  that consequential side effects remain deterministically mediated.

## Decision

When a pull request is Ready for review, is intended for normal integration, and
the hosting platform and repository permit auto-merge, automated coding agents
SHOULD enable auto-merge.

Enabling auto-merge delegates only the mechanical merge operation.  It SHALL NOT
constitute approval and SHALL NOT bypass or replace any required repository gate.

Auto-merge is appropriate only when:

- the pull request is complete for its intended scope;
- the pull request is Ready for review;
- ordinary repository review and CI requirements remain enforceable;
- no additional maintainer decision is known to be required before merge; and
- the hosting platform will refuse to merge until every required gate is
  satisfied.

A required CODEOWNERS review remains a human authorization gate.  Auto-merge may
be armed before that approval occurs because the hosting platform will not merge
the pull request until the required CODEOWNERS approval and all other configured
requirements are satisfied.

An automated agent SHOULD NOT enable auto-merge when:

- the pull request remains a draft;
- the maintainer has requested manual merge control;
- unresolved architecture, security, compatibility, release, or scope questions
  require an explicit decision;
- repository merge requirements are unknown or cannot be verified to remain in
  force; or
- enabling auto-merge would weaken or obscure an intended authorization boundary.

When auto-merge is enabled, the repository's normal merge strategy and reviewed
commit-title or release-classification requirements remain authoritative.

## Security and Trust Boundary

Auto-merge changes the timing of a future repository mutation but does not change
which conditions authorize that mutation.

Required reviews, CI checks, branch protection, rulesets, and equivalent hosting
controls are trusted deterministic gates.  The coding agent is permitted to
request that the platform perform the merge later, but it is not permitted to
declare those gates satisfied or bypass them.

A repository MUST NOT treat the agent's request to enable auto-merge as evidence
that the pull request is safe, approved, or authorized.  The platform's enforced
gate state is the relevant evidence for whether merge may proceed.

If a platform's auto-merge implementation cannot preserve the repository's
required authorization and validation gates, this decision does not authorize its
use.

## Alternatives Considered

### Require a Maintainer to Perform Every Merge Manually

Rejected as the default because the final click does not necessarily represent an
additional decision when CODEOWNERS approval, CI, branch protection, and other
required gates have already expressed the intended authorization.

Repositories may still require manual merge when they intentionally use that
action as a separate decision point.

### Allow Agents to Merge Immediately After Creating a Pull Request

Rejected because creation of a pull request is not approval.  Immediate merge
would collapse implementation, review, and authorization into the agent's own
action and could bypass the project's human-review model.

### Enable Auto-Merge on Draft Pull Requests

Rejected because Draft status explicitly communicates that known work or author
review may still be incomplete.  Auto-merge belongs after the pull request is
Ready for review.

### Require Auto-Merge in Every Repository

Rejected because repository capabilities and governance differ.  Auto-merge is a
recommended workflow when the platform can enforce the intended gates, not a
requirement to weaken repository-specific controls.

### Depend on Conversational Memory Instead of Repository Governance

Rejected because conversational context is not a durable or reviewable
engineering contract.  The behavior belongs in the released standards so humans
and future coding-agent sessions can discover it from repository governance.

## Consequences

Positive consequences include:

- human approval remains the authorization boundary where repositories require
  it;
- agents no longer require a separate follow-up request merely to perform the
  mechanical merge;
- pull requests can merge promptly after all required gates succeed;
- the behavior becomes portable across conversations and coding agents through
  released repository governance; and
- the distinction between approval and merge execution becomes explicit.

Tradeoffs include:

- repositories must rely on their hosting-platform gate configuration to express
  the intended merge requirements correctly;
- maintainers who intentionally want a separate final manual decision must state
  that policy or decline auto-merge;
- an agent must understand enough repository governance to know whether
  auto-merge is appropriate; and
- auto-merge may cause a pull request to merge soon after its final required gate
  succeeds, leaving less time for optional post-approval observation.

## Expected Outcomes

Automated coding agents working in repositories that adopt the Development
Workflow and Backlog Governance standard will normally enable auto-merge after a
pull request becomes Ready for review when the repository permits it.

Repositories that require CODEOWNERS approval will continue to receive that human
approval before merge.  Once the approval and all other required gates are
satisfied, the hosting platform will perform the merge without requiring an
additional conversational round trip.

Repository-specific governance may require manual merge when a separate final
decision is intentional.

## Relationships

This decision extends Development Workflow and Backlog Governance with a
post-review merge-handling convention.

It complements ADR-010's AI-safety model by keeping consequential mutation under
deterministic platform mediation and by refusing to treat agent intent as evidence
that review or authorization requirements have been satisfied.

It complements ADR-011's agent workflow guidance by making another aspect of
agent-created pull-request handling explicit and machine-discoverable.
