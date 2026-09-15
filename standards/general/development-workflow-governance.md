# Development Workflow and Backlog Governance

## Status

Recommended repository governance

## Purpose

This document defines repository-level governance for controlling development
scope, capturing newly discovered ideas, and maintaining a reviewable backlog.
Its purpose is to preserve task boundaries, planning visibility, and team-style
engineering discipline even when a project is maintained by one person or worked
on as a hobby.

Repositories adopting this document SHOULD treat it as governing policy unless a
repository-specific ADR, policy, security process, or other explicit governance
supersedes it.

## Goals

This policy is intended to:

- keep in-flight work aligned with the task that authorized it;
- prevent unrelated ideas from silently expanding the scope of active work;
- ensure useful development ideas are captured rather than forgotten;
- keep future work visible, prioritizable, and reviewable in the backlog;
- make scope decisions explicit when reasonable people could classify an idea
  differently;
- support small, cohesive pull requests and reviewable changes;
- give humans and automated coding agents the same expectations for scope control;
  and
- encourage professional team practices regardless of project size or staffing.

## Normative Language

The terms MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are to be interpreted as
normative requirements.

## Professional Team Model

A repository SHOULD be operated as though multiple professional contributors may
need to understand, review, prioritize, continue, or audit the work later.

This expectation applies even when:

- the repository is a hobby project;
- only one maintainer currently works on the project;
- an automated coding agent performs most or all implementation work;
- a change appears small enough that adding it opportunistically would be
  convenient; or
- the maintainer already understands the surrounding context without written
  documentation.

Individual familiarity with a project is not a substitute for visible scope,
recorded decisions, and a maintained backlog.

## Authorized Task Scope

Development work MUST remain within the scope of the currently authorized task.

The active task may be defined by one or more of the following:

- a GitHub issue;
- a pull request description;
- explicit maintainer instructions;
- acceptance criteria;
- an ADR or other governing decision;
- a bug report;
- a planned maintenance item; or
- another repository-recognized work item.

Implementations MAY include work that is reasonably necessary to complete the
current task correctly, including required tests, documentation, compatibility
adjustments, error handling, and directly necessary supporting changes.

Work MUST NOT be added merely because it is nearby, interesting, cleaner, or
convenient while the relevant files are already being modified.

## New Ideas Discovered During Development

A development idea discovered while working on an active task MUST be evaluated
against the current task's scope before implementation.

If the idea is outside the current task, it SHOULD be recorded as a separate issue
in the repository backlog rather than incorporated into the in-flight change.

Examples include:

- a useful feature unrelated to the current acceptance criteria;
- a refactoring opportunity that is not necessary for the requested behavior;
- a documentation improvement outside the area being changed;
- a performance optimization discovered while fixing a correctness bug;
- a tooling enhancement that would make future work more convenient;
- a cleanup opportunity in adjacent files; or
- a broader architectural improvement exposed by a narrow implementation task.

Capturing an idea in the backlog does not imply that it will be implemented.  It
means the idea remains visible so it can be reviewed, prioritized, refined,
rejected, or scheduled deliberately.

## When Scope Is Ambiguous

When it is genuinely unclear whether a newly discovered idea belongs in the
current task or should become a separate backlog item, the implementer MUST ask
for clarification before materially expanding the active task.

The question should identify:

- the newly discovered work;
- why it may be relevant to the current task;
- why it may represent separate scope; and
- the practical consequence of including or deferring it.

A coding agent MUST NOT resolve material scope ambiguity by silently choosing the
larger implementation.

If immediate clarification is unavailable and the current task can be completed
without the additional work, the conservative default is to preserve the current
task boundary and record the idea in the backlog.

## Necessary Work Versus New Scope

Not every newly discovered change is separate scope.

Work normally remains part of the current task when it is necessary to satisfy the
established contract of that task.  Examples include:

- adding tests required to demonstrate the requested behavior;
- updating documentation made inaccurate by the current change;
- fixing a directly introduced regression;
- preserving an existing public interface while implementing the task;
- handling an error path required for the requested behavior to be correct; or
- making a narrowly necessary compatibility change without which the task cannot
  function as specified.

Work is more likely to be separate scope when the current task can be completed
correctly without it and the work introduces a distinct capability, policy,
refactoring objective, architectural decision, or maintenance concern.

The size of a change is not the deciding factor.  A one-line unrelated cleanup may
still be out of scope, while a larger supporting change may be necessary to fulfill
the active task correctly.

## Backlog Issues

A backlog issue SHOULD contain enough information for another contributor to
understand why the work was captured and decide what to do with it later.

Where practical, include:

- a concise description of the idea or problem;
- relevant context explaining where it was discovered;
- the expected value or reason for considering the work;
- known constraints or dependencies;
- links to related issues, pull requests, ADRs, or source locations; and
- any important distinction between the backlog item and the task during which it
  was discovered.

A backlog issue SHOULD describe the problem or desired outcome without prematurely
committing the project to a particular implementation unless that implementation
has already been decided through normal governance.

## Relationship to Pull Requests

A pull request SHOULD remain cohesive around its declared purpose.

Newly discovered backlog items SHOULD NOT be folded into the pull request merely to
avoid opening another issue or future pull request.

When an out-of-scope issue is discovered during pull request work, the pull request
MAY reference the new issue when that context helps reviewers understand what was
intentionally deferred.

A reviewer SHOULD be able to determine which requirements the pull request intends
to satisfy without separating unrelated opportunistic changes from the primary
work.

## Relationship to Architecture Decisions

A newly discovered idea that would introduce meaningful architecture, interface,
compatibility, security-boundary, persistence, deployment, or other consequential
behavior MAY require an ADR before implementation according to the repository's
architecture governance.

Creating a backlog issue does not replace an ADR when an architectural decision is
required.  The issue records work to be considered; the ADR records the decision
that governs how consequential work will be performed.

## Security-Sensitive Findings

Security-sensitive findings MUST follow the repository's security reporting and
handling policy.

A public backlog issue MUST NOT be created when doing so would disclose a
vulnerability, secret, exploit path, sensitive configuration, or other information
that the repository's security policy requires to remain private.

The scope-control principle still applies: unrelated security remediation should
not be silently mixed into ordinary work.  However, the finding must be captured
through the appropriate secure process rather than the normal public backlog.

If a security finding creates an immediate risk that materially affects whether
the active task can proceed safely, the implementer SHOULD stop and escalate the
finding according to repository policy.

## Defects Discovered During a Task

A defect discovered during development is not automatically part of the current
task merely because the defect appears in code being touched.

The defect MAY be fixed within the current task when:

- the active change introduced the defect;
- the defect prevents the requested work from functioning correctly;
- the task explicitly includes correcting that behavior; or
- leaving the defect unresolved would make the completed change knowingly unsafe
  or invalid under an established project contract.

Otherwise, the defect SHOULD normally be captured as a separate backlog issue.

When the distinction is unclear and resolving it would materially affect scope,
ask before proceeding.

## Refactoring and Cleanup

Refactoring, formatting, renaming, modernization, dependency changes, and cleanup
SHOULD be limited to what the active task requires.

Do not broaden an implementation to clean surrounding code merely because the
opportunity is visible.

A useful refactoring or cleanup idea discovered during an unrelated task SHOULD be
recorded as a backlog issue when it is worth preserving.

Small mechanical changes MAY remain in scope when they are necessary to make the
requested modification safe, understandable, testable, or compliant with governing
standards.

## Guidance for Automated Tools and Agents

Automated tools, coding agents, and repository assistants MUST preserve task scope
as deliberately as human contributors.

When working on a repository, an agent SHOULD:

1. identify the current task and its acceptance criteria before implementation;
2. distinguish required supporting work from newly discovered independent work;
3. avoid unrelated cleanup, feature additions, refactoring, or architectural
   changes;
4. capture valuable out-of-scope ideas as backlog issues when repository access
   permits;
5. link backlog issues to the context in which they were discovered when useful;
6. ask when a material idea could reasonably belong either to the active task or
   to the backlog;
7. prefer the narrower task boundary when clarification is unavailable and the
   task can be completed correctly without expansion;
8. follow private security-reporting procedures instead of public issue creation
   for sensitive findings;
9. avoid assuming that a maintainer's hobby project permits lower process
   discipline; and
10. preserve enough written context that another contributor or later agent can
    understand why work was included, deferred, or separated.

An agent MUST NOT treat autonomy as permission to expand scope silently.

## Examples

### Adjacent Feature Idea

Current task:

```text
Fix incorrect parsing of empty configuration values.
```

While implementing the fix, the contributor notices that environment-variable
interpolation would be useful.

Environment-variable interpolation is a separate feature.  The parsing fix should
remain focused, and the interpolation idea should be captured as a backlog issue.

### Required Supporting Test

Current task:

```text
Reject malformed dependency declarations.
```

The existing test suite has no malformed-input coverage.  Adding focused tests for
the newly required rejection behavior is part of the current task because those
tests provide evidence that the requested behavior works.

### Unrelated Cleanup

Current task:

```text
Document the release checksum format.
```

While editing the document, the contributor notices inconsistent headings in a
separate maintenance guide.  The heading cleanup is not necessary to document the
checksum format and should not be added opportunistically.  If worth preserving,
it should become a backlog issue.

### Ambiguous Refactoring

Current task:

```text
Add support for a second output format.
```

The existing serializer can technically support the change, but extracting a
shared serialization abstraction may make the implementation substantially easier
to maintain.  If the abstraction is a material design change and it is unclear
whether it belongs in the task, ask before expanding the implementation.

### Security Finding

Current task:

```text
Improve command help text.
```

The contributor notices a possible credential exposure path in unrelated logging
code.  The finding should not be added as a public backlog issue when disclosure
would create risk.  It should be reported through the repository's security
process and escalated according to that policy.

## Review Checklist

Before completing or approving a pull request, reviewers SHOULD verify that:

- the change remains aligned with the declared task;
- required supporting changes are distinguishable from unrelated improvements;
- unrelated ideas discovered during development have not been silently included;
- worthwhile deferred ideas have been captured in the backlog where appropriate;
- any material scope ambiguity was resolved explicitly;
- security-sensitive findings were handled through the appropriate process;
- architectural decisions were not smuggled into implementation without required
  governance; and
- the resulting change is cohesive and independently reviewable.

## Repository Adoption

A repository adopting this policy SHOULD:

1. maintain an issue tracker or equivalent visible backlog for deferred work;
2. make the active task identifiable through issues, pull requests, maintainer
   instructions, or another reviewable mechanism;
3. tell contributors and coding agents to preserve task boundaries;
4. require clarification when material scope is ambiguous;
5. maintain a security reporting path for findings that must not enter the public
   backlog;
6. encourage pull requests that are cohesive around one declared purpose; and
7. treat backlog hygiene as normal engineering work rather than optional project
   administration.

Repository-specific governance MAY define additional triage states, issue labels,
project boards, planning workflows, or thresholds for when a new issue is required.
Those refinements should preserve the core principle that independent development
ideas remain visible and separately reviewable rather than being silently merged
into unrelated work.

## Governing Principle

The current task defines what is being changed now.  The backlog preserves what may
be changed later.

When a useful idea falls outside the current task, record it rather than losing it
or silently expanding scope.  When the boundary is materially uncertain, ask.

Professional engineering discipline is valuable even when the entire team is one
person.
