# ADR-016: Adopt a Named, Optional-Presence GitHub CI Check Gate

Date: 2026-11-11

## Status

Accepted

## Decision

Introduce a cross-repository GitHub Actions CI check-name taxonomy and a
standard **optional-presence** aggregate check implementation using the
published `matiasalbarello/wait-on-check-action-ts` Marketplace action.

A consuming repository MAY initially contain zero CI checks matching the
taxonomy, and this absence is **not a gate failure**. When the action sees
matching checks on the configured revision, their conclusions must be one
of `success`, `skipped`, or `cancelled`. The aggregate's stable published
job/check name is
`test-gate`. The accompanying ruleset example requires that exact status
check only when explicitly imported and activated by a repository
administrator.

The policy is deliberate: this gate establishes only that **all matched
checks observed by the action have one of the configured acceptable
conclusions**. Skipped or cancelled checks may be accepted without
executing their intended tests. It does not establish that a required
test suite exists, that a workflow is enabled, that all expected jobs ran,
or that every independent verification boundary passed.

## Context

The coding standards repository distributes a complete, pinned library
to consumers, including general testing rules (ADR-007) and non-normative
reference templates and examples (ADR-009). The general testing model
favors deterministic tests, credible aggregate failures, observable
behavior, and safe CI credential boundaries. Repositories vary in maturity:
an application derived from a template may have no application tests on
its first commit, while a mature repository may run unit, integration,
security, lint, build, compatibility, and E2E workflows independently.

GitHub repository rulesets require individually named check contexts;
they do not support treating a regular expression as a required check.
Consequently, evolving test job names and matrix structures can require
repeated manual branch-protection updates. A stable aggregate job can
reduce that administrative maintenance when its actual guarantees are
clearly understood.

The team considered custom GitHub Actions workflow metadata, repository
discovery, and a hand-maintained API poller, including a Certbotbot
proof-of-concept PR #304. The preferred approach now is the existing
Marketplace check-waiting action, accepting its scope and limitations
instead of developing a bespoke policy engine.

The action matches GitHub **check-run job names**, which are distinct
from workflow filenames and top-level workflow display names. Its
upstream defaults accept `skipped` and fail when no matching checks
exist. Those defaults do not implement the chosen policy.

## Decision Drivers

- Support a clean initial repository created from a shared template.
- Standardize recognizable, extensible check names without requiring
  every repository to implement every category.
- Allow independent workflows and parallel test matrices to continue.
- Reuse a maintained Marketplace action instead of a custom polling engine.
- Expose one stable required-status context for a separately reviewed
  GitHub repository ruleset.
- Preserve credible failure semantics for **observed** matching checks.
- Make the known early-success and missing-check limitations explicit.
- Preserve read-only PR execution and review-based activation controls.
- Separate normative policy from non-normative, explicitly adopted examples.

## Chosen Naming Contract

When applying this profile, GitHub Actions check-run job names SHOULD use
one of these case-sensitive lowercase prefixes, either as the entire
name or followed by a hyphen and nonempty suffix:

- `test`
- `e2e` or `end-to-end`
- `integration`
- `lint`
- `security`
- `build`
- `compat`

The family-specific test expression is `^test(-.+)?$`. It admits
`test` and `test-unit` but excludes `testy-little-test`,
`testing`, and `test-`.

The combined action selector is:

```regex
^(test|e2e|end-to-end|integration|lint|security|build|compat)(-.+)?$
```

The gate itself, `test-gate`, is a valid match and must be excluded by
its explicit self-exclusion setting. A match is based on the actual
published check-run name, including any matrix or reusable-workflow
qualification. Existing repositories retain their original required
check identities until they deliberately migrate them.

## Optional-Presence Semantics

The standard configures:

```yaml
allowed-conclusions: success,skipped,cancelled
fail-on-no-checks: 'false'
```

The first setting accepts observed `success`, `skipped`, and `cancelled`
conclusions, while rejecting all other conclusions, including `failure`
and `timed_out`. The second tolerates an empty observed check set. No
category is mandatory to exist solely by being included in the regex.
An accepted cancellation may represent interrupted or superseded work;
an accepted skip or cancellation MUST NOT be described as tests passing.

This explicitly supersedes, for this new profile, the earlier design
discussion that proposed at least one ordinary `test` check in every
repository. It does not supersede existing repository-specific testing
or CI obligations and must not be used to erase required coverage from
an established project.

The action does not know the expected inventory. It can finish after
one matching check succeeds while other intended checks have not yet
registered. Disabled workflows, conditional jobs, stale refs, and check
names outside the selector may produce no matching result. Thus a
required `test-gate` check does not prove that matching tests ever ran.
No standards text or template may claim otherwise.

## Aggregate Workflow and Dependency Boundary

One separate GitHub Actions workflow publishes the `test-gate` check,
rather than having every test workflow invoke the waiting action.
The recommended action is `matiasalbarello/wait-on-check-action-ts`, pinned
to the full `v1.2.0` source commit
`8087812521cdb59ebc7751984b31b17209b30eeb`. The job uses a
read-only token with `checks: read` and `contents: read`, excludes
itself with `running-workflow-name: test-gate`, and has a bounded
job timeout. Future action revisions require dependency review.

The trusted computing base expands to GitHub Actions, the GitHub Checks
API, the selected Marketplace action, the GitHub-hosted Node.js 24 runner,
and the action's bundled JavaScript and transitive npm dependencies. Pinning
fixes source identity; it is not a supply-chain or correctness guarantee.
The TypeScript action paginates Checks API responses, but does not reduce
duplicate names to the latest check run. An older failed check can therefore
remain relevant after a newer run succeeds. Its published tests and successful
release CI provide useful evidence, not proof of complete behavioral
compatibility with the Ruby original.

The reference workflow selects the PR head SHA, appropriate for
same-repository branch-push tests. GitHub PR-triggered checks may attach
to a synthetic merge SHA instead. A single API ref cannot necessarily
see both. Forks, merge queues, branch protection's tested revision,
disabled workflows, and reruns require repository-specific verification.
The reference is not a universal drop-in CI security gate.

## Ruleset Reference and Activation Boundary

An importable GitHub repository ruleset JSON example names the exact
status context `test-gate`. The regex is evaluated by the action,
not by the ruleset. The example targets `refs/heads/main` and uses
`enforcement: active`, so an administrator must review the imported
scope before clicking Create. Merely committing this JSON in the
standards repository, or adopting a standards release, does not activate
GitHub rulesets.

The ruleset example does not encode a complete repository review policy.
It must be evaluated alongside existing CODEOWNERS review, pull request
and release protections, and previously required checks. A successful
aggregate cannot replace independent mandatory checks absent an
explicit evidence-based decision that coverage and trust are preserved.

Repository-local configuration is a separate reviewed adoption action.
ADR-003's pinned, managed `doc/standards/` snapshot and ADR-009's
non-normative template/example boundary remain unchanged. The
reference workflow YAML and ruleset JSON live beneath
`standards/examples/`, not as automatically active files beneath
`.github/`.

## Threats, Mitigations, and Residual Risk

| Threat or failure | Mitigation or explicit limitation |
| --- | --- |
| A fresh repository has no tests | `fail-on-no-checks: 'false'` intentionally allows it |
| A matched job fails or times out | Restrict `allowed-conclusions` to `success,skipped,cancelled`; neither `failure` nor `timed_out` is accepted |
| A matched job is skipped or cancelled | Explicitly accept it as a permitted conclusion, without claiming its tests executed or passed |
| The gate sees its own `test-gate` check | Explicitly exclude that check from matching |
| A required workflow was disabled | Not independently detected; retain separate mandatory check controls |
| One check finishes before other expected checks appear | Early success is possible; no complete-inventory claim |
| A PR changes the gate that judges the PR | Require existing human review and independently trusted policy; do not claim the candidate-controlled workflow is an authorization boundary |
| GitHub reports PR/push checks on different SHAs | Document and verify the intended ref; do not assume universal visibility |
| A third-party action or dependency is compromised | Pin exact source, limit token authority, review dependency changes; residual transitive supply-chain risk remains |
| Ruleset import changes merge eligibility | Require separate, reviewed administrative activation, preserving prior check and CODEOWNERS gates |
| GitHub API rate limits or ref selection omit checks | Use a read-only token, verify the ref, and retain the incomplete-inventory limitation; pagination does not establish expected coverage |
| Duplicate check names after retries or new suites | The TypeScript action evaluates returned duplicates; an older failed run may keep the gate red after a newer success |

## Considered Alternatives

### Require at least one test in every repository

Rejected for the chosen baseline because a newly created template
repository should be able to pass before it contains testable application
code. A stronger rule remains available through repository-specific
governance.

### Require at least one check in every category

Rejected because not every project has E2E, integration, security,
build, or compatibility workflows. Optional presence is uniform across
the enumerated categories.

### Build a custom required-workflow inventory and poller

Deferred in favor of the Marketplace integration's lower maintenance
burden. A strict expected-inventory contract would require additional
engineering and cannot be inferred from regex selection alone.

### Require every observed check to conclude `success`

Rejected for the chosen optional-presence profile. The operator explicitly
permits `skipped` and `cancelled` as acceptable GitHub check conclusions,
including intentional conditional runs and cancelled/superseded work. This
reduces coverage evidence: an accepted conclusion is not necessarily proof
that a test ran or completed. Repositories needing strict completion MUST
retain independently enforced checks or establish stronger local policy.

### Use the original Ruby Marketplace action

Considered because `lewagon/wait-on-check-action` is established and its
v1.9.1 release can select the latest run when check names are duplicated.
Rejected for this reference in favor of the TypeScript port's native Node.js 24
runtime, no per-run Ruby/Bundler installation, and complete API pagination.
This choice accepts its different duplicate-run behavior and smaller release
history; it is not evidence that the TypeScript implementation is a drop-in
replacement for all existing consumers.

### Require the waiting action in every test workflow

Rejected due to duplication, possible circular dependencies, and the
ability to observe parallel workflows from one aggregate job instead.

### Name the branch ruleset's required check with a regex

Not supported by GitHub's ordinary required-status-check rules.
The check name must be literal; only the action's selector uses regex.

### Auto-install workflows and rulesets with standards adoption

Rejected under ADR-003 and ADR-009. Doing so would modify a second
active configuration surface without independent local approval.

## Consequences and Expected Outcomes

A released standards snapshot now documents a common check naming
vocabulary, a pinned check-waiting action, and an exact ruleset context.
A template-derived repository can initially have no matching jobs,
adopt the gate explicitly, and receive a successful aggregate without
a manufactured missing-check failure. Existing CI may remain parallel,
and the ruleset reference is portable to repositories after deliberate
administrative review.

The tradeoff is intentionally weaker evidence. A green gate states
only that its observed matching checks concluded `success`, `skipped`,
or `cancelled`, not that any given test suite executed or passed. Adopters
cannot claim compliance, complete security validation, or successful E2E
testing merely because the gate is green.

Introducing a new general standard and reference examples is a
standards-library change that will reach consumers only through a
subsequent released version and their normal pinned adoption PRs.
The change does not mutate active repository CI or rulesets by itself.

## Relationship to Prior Decisions

- ADR-003: pinned standards releases and explicit consumer adoption.
- ADR-005/006: Accepted ADR status and maintained current-decision digest.
- ADR-007: general test semantics and evidence preservation.
- ADR-009: separate normative standards and non-normative references.
- ADR-012/015: automatic merge only under verified human and CI protections.
