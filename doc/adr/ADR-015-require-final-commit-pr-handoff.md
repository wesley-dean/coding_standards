# ADR-015: Require Final-Commit PR Handoff Independent of CI Completion

Date: 2026-11-10

## Status

Accepted

## Context

The Development Workflow and Backlog Governance standard already encourages
draft pull requests followed by an explicit Ready-for-review declaration.
ADR-012 permits agents to enable auto-merge after the required review and CI
gates. The prior rules say verification is complete before a Ready transition,
however, and only recommend that agents enable auto-merge.

As a result, an agent can finish all currently planned commits while CI is
still running, end its work session, and leave the PR in Draft. The maintainer
cannot reliably distinguish ongoing implementation from a completed agent
handoff. They must ask whether it is ready, manually transition it, and often
enable auto-merge even after reviewing and approving it.

CI completion is a separate property from author-controlled work completion.
Parallel CI checks may have different completion times, and the agent should
not wait for them simply to make a PR available for human review.

## Decision Drivers

- Make the agent's completion and review handoff explicit and dependable.
- Avoid requiring the maintainer to investigate completed Draft PRs.
- Permit human review before independently executed CI finishes.
- Preserve required CI, CODEOWNERS, branch protection, and security reviews.
- Avoid unreviewed auto-merges in repositories lacking enforced human gates.
- Preserve existing CI scheduling, including parallel matrices.
- Disclose failed transitions, unknown gate configuration, and verification.
- Avoid implied background agent monitoring or unobserved success claims.

## Decision

### Final planned commit and readiness

Agents SHOULD initially create PRs in Draft. An automated coding agent MUST
promptly mark its PR Ready for review when all of the following are true:

1. All currently planned authorized implementation, documentation, and test
   changes are committed and pushed to the PR branch.
2. The agent presently expects no additional implementation commit.
3. Available author-side validation has been performed to the extent practical,
   and its results, limitations, and omissions are accurately disclosed.
4. The PR title, description, issue linkage, and stated risks reflect the diff.
5. No unresolved material architecture, scope, security, compatibility, or
   release decision prevents final human review.

The agent MUST perform the Ready transition before ending its implementation
handoff. The prospect of an unanticipated future fix, and CI checks that are
still pending or running, MUST NOT by themselves keep a completed PR in Draft.

Ready for review means that the author has finished planned work and made the
PR available for human review. It does not mean CI has passed, merge is
authorized, or the underlying issue or story is Done.

A known failing check that the agent is actively correcting, or a known
unfinished implementation change that requires another planned commit, is
different from merely pending CI. The PR SHOULD remain Draft while that work
continues. A failed required check MUST continue to block merge.

### Corrections after readiness

A later unexpected test failure or review finding does not automatically
invalidate an earlier valid handoff. Narrow corrective commits MAY be pushed
while Ready if the PR remains accurate and reviewable. Substantial resumed
implementation, or a newly unresolved material decision, SHOULD return the
PR to Draft when platform permissions allow it.

Configured review protections, including stale-approval dismissal or
most-recent-reviewable-push approval, remain authoritative. Repositories
SHOULD configure such protections, and agents MUST NOT bypass existing ones.

### Mandatory auto-merge when safe

After an agent marks a PR Ready, it MUST enable platform auto-merge if all
of the following hold:

- The repository and platform support the chosen merge strategy.
- Required CI, security, review, and CODEOWNERS gates remain enforced until
  the merge.
- No unresolved decision or separate manual merge authorization is needed.
- The maintainer has not explicitly reserved the final merge action.

Pending or running CI alone is not a reason to defer arming auto-merge
when those checks are required before the platform permits merging.

The agent MUST NOT enable auto-merge if gate enforcement cannot be verified,
if human review is expected but unenforced and the PR could merge immediately,
if a material decision remains unresolved, or if auto-merge would weaken a
required authorization or validation boundary. Neither issue approval nor
agent intent substitutes for required human PR review.

Enabling auto-merge delegates only the mechanical merge action to the hosting
platform. The platform must independently enforce required gates. A failed
required check cannot be waived to make the PR mergeable.

### Verified end-of-session handoff

Before ending implementation, the agent MUST verify and report the remote
PR URL, Draft/Ready state, actual auto-merge state, and the known status
of checks (passing, pending, failing, or unavailable). If marking Ready or
arming auto-merge fails, is unsupported, or is unsafe due to unverifiable
gate configuration, the agent MUST say so explicitly. It MUST NOT claim
unobserved success or promise future monitoring without a real mechanism.

This policy does not alter CI triggers, job dependencies, release pipelines,
or issue-level approval and Definition-of-Done rules. It is published in the
shared Development Workflow and Backlog Governance standard. Non-normative
reference PR templates and examples illustrate its use but are not
automatically installed into consuming repositories.

## Alternatives Considered

### Wait for all CI checks to finish before marking Ready

Rejected because CI may be slow or parallel, and finishing CI does not
define whether further author commits are planned. It strands finished PRs.

### Mark PRs Ready immediately upon creation

Rejected because substantial author work or important design decisions
may still be unfinished.

### Keep both transitions as recommendations

Rejected because optional timing has allowed completed Draft PRs to persist,
requiring manual intervention and extra maintainer clicks.

### Enable auto-merge even without verified merge protection

Rejected because a PR can merge without human approval if the expected
review gate is not enforced. Agents must fail closed and report that case.

### Return every Ready PR to Draft after any CI failure

Rejected because narrow corrective work need not invalidate the previous
author handoff and a required failing check already prevents merge.

### Introduce a single aggregate test workflow

Rejected as unrelated. Cross-workflow gating, required check configuration,
and test parallelism are separate concerns and remain unchanged.

## Consequences

### Positive

- Human review can begin as soon as author work is complete.
- Agents have an explicit final action and report its verified result.
- Safe auto-merge avoids another manual merge click after required approval.
- Existing parallel test scheduling remains intact.
- Known blockers and missing platform permissions become visible.

### Tradeoffs and risks

- Ready PRs may still have pending or failing CI; reviewers must not
  mistake Ready for test success.
- Additional corrective commits may require renewed review.
- Correct platform branch protection and required checks remain essential.
- Some GitHub integrations cannot inspect protection settings and therefore
  cannot safely enable auto-merge; those cases must be disclosed.
- This ADR does not configure required checks or protections on its own.

## Compatibility and Migration

The agent's conditional Ready and auto-merge obligations are strengthened
from recommendations and ambiguous timing to mandatory actions. This is a
breaking change to governance for agents adopting the new standards, and
should receive a major-version classification under the repository's
Conventional Commit release rules.

No runtime API, Bash implementation, release archive format, branch naming,
or CI scheduling changes. Existing PRs are not retroactively transitioned.
Consuming repositories adopt the revised policy only through a verified
released standards snapshot. A repository-specific accepted ADR or policy
may require manual merge while preserving its human review gates.

## Expected Outcome

An agent pushes the final planned commit, completes available author-side
verification, marks the PR Ready, and arms auto-merge when enforced gates
make it safe. The maintainer reviews while CI may still be running. GitHub
merges once the required checks and human approval are satisfied.

## Relationships

- [ADR-012](ADR-012-enable-auto-merge-after-repository-review-gates.md)
  establishes safe auto-merge and remains authoritative for trust boundaries;
  this decision strengthens its conditional agent default from SHOULD to MUST.
- [ADR-010](ADR-010-adopt-ai-safety-standard-focused-on-model-fallibility.md)
  separates agent claims from independent authorization and validation.
- [ADR-011](ADR-011-adopt-conventional-branch-naming-for-agent-work.md)
  governs agent branch naming, which remains unchanged.
- [ADR-009](ADR-009-add-reusable-reference-templates.md)
  keeps reference templates distinct from repository-local active templates.
- [ADR-013](ADR-013-adopt-opt-in-three-phase-development-governance.md)
  keeps issue authorization and completion separate from PR readiness.
- [ADR-014](ADR-014-make-approved-issue-label-authoritative.md)
  clarifies that issue approval cannot replace a required PR review.
