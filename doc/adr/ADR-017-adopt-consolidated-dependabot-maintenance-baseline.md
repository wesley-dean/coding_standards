# ADR-017: Adopt Consolidated Dependabot Maintenance as a Shared Baseline

Date: 2026-11-12

## Status

Accepted

## Decision

The standards library SHALL define a GitHub Dependabot maintenance baseline
aimed at reducing recurring pull-request review work across many independently
managed repositories. The recommended default for GitHub Actions dependencies
is a **weekly scheduled version-update group**, with a **seven-day cooldown**,
a wildcard dependency pattern, and **no SemVer update-type restriction**.
Major, minor, and patch releases therefore remain eligible for the same
routine grouped PR.

The grouping is explicitly limited to `applies-to: version-updates`.
Security updates retain their independent triggering and are not delayed by
the routine version-update cooldown or weekly schedule. Major-containing
groups remain subject to deliberate review and must not silently enter
non-major auto-merge paths.

The canonical requirements live in
[Consolidated Dependabot Version Update Standard][dependabot-standard].
A non-normative `dependabot.yml` example travels with the standards
archive but is not installed into any active repository by standards adoption.

## Context

The maintainer operates dozens of repositories. Historically, regular
Dependabot activity across those repositories produced many individual PRs,
often for related GitHub Actions dependencies updated in the same week.
Repeatedly reviewing, approving, and merging similar PRs consumed attention
without necessarily improving scrutiny of higher-risk dependency changes.

The pilot implementation in
[template-bash ADR-018][pilot-adr]
grouped routine GitHub Actions version updates using a wildcard. A
subsequent pilot PR bundled six non-major dependency updates and passed
the relevant available PR checks. The pilot established that grouping
worked for that instance; it did not prove mixed-major grouping or a
specific long-term reduction in review volume.

The same model was subsequently adopted in adrctl, bashdeps, bashlog,
and mktext. Those repositories have materially equivalent GitHub Actions
Dependabot configurations: weekly schedule, seven-day cooldown, wildcard
group `actions-version-updates`, and `applies-to: version-updates`
without `update-types` filtering.

The earlier minor/patch-only grouping design often left major upgrades
as individual PRs, undermining consolidation. For the pilot, the team
deliberately selected major/minor/patch grouping **together**, but kept
major-containing PRs out of non-major automated merge authorization.
That distinction is material and is preserved here.

The coding standards repository is the canonical home for reusable
cross-repository governance. Prior work established an immutable released
standards archive (ADR-003), non-normative templates and examples that
are not automatically activated (ADR-009), review-gated auto-merge
(ADR-012/015), and independent test evidence (ADR-007/016). Consolidated
dependency governance belongs in this corpus, while individual repositories
retain authority over actual Dependabot configuration and merge protections.

## Decision Drivers

- Reduce the number of routine Dependabot PRs competing for attention.
- Preserve dependency-specific inspection within each combined change.
- Use successful practices from existing pilots rather than inventing a
  materially different model under the name "balanced".
- Retain risk-sensitive handling of breaking and high-authority updates.
- Keep vulnerability remediation independent of routine update cadence.
- Avoid hiding a backlog behind a restrictive open-PR limit.
- Permit smaller repositories to adopt slower maintenance cadence explicitly.
- Respect per-repository dependency ecosystems and existing ADRs.
- Keep active repository changes separate from adopting standards.
- Measure whether grouping actually reduces review volume after adoption.

## Decision Details

### Weekly, seven-day baseline

For an actively maintained GitHub Actions ecosystem, the shared reference
SHALL use:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    cooldown:
      default-days: 7
    groups:
      actions-version-updates:
        applies-to: version-updates
        patterns:
          - "*"
```

The reference also retains the pilots' `fix` commit prefix and scoped
commit messages. It intentionally omits `prefix-development` because
GitHub documents that option for selected package ecosystems other than
`github-actions`; its presence in existing pilot YAMLs is not a requirement
of the adopted grouping policy.

A wildcard group with no `update-types` restriction admits all
eligible SemVer update levels. The policy is not "group minor/patch and
separate all majors"; major updates are eligible for the routine batch.
Major is still a risk/review classification.

The weekly cadence is a default, not a requirement to pick the same
weekday across every repository. A lower-activity repository MAY use
a monthly schedule and, if justified, a longer ordinary version-update
cooldown (up to 30 days). Such decisions SHOULD be visible local policy
and must not alter prompt security-update behavior.

No restrictive `open-pull-requests-limit` is added to the baseline.
A later limit must be evaluated against the actual unresolved backlog.

### Security updates remain separate

The version-update group MUST NOT include a security-update grouping
rule. The seven-day `cooldown` applies to version updates, not security
updates. Independent security update handling depends on GitHub's
dependency graph, alerts, and Dependabot security-update feature state,
which an example YAML file cannot prove or enable.

A future explicit security-update grouping decision is possible, but
is separate scope. The baseline neither claims nor requires a weekly
schedule for security fixes.

### Review and auto-merge

Every change in a grouped PR remains reviewable. Maintainers must assess
the highest-risk dependency in the group, especially actions that can
write to the repository, obtain credentials, create releases or tags,
sign artifacts, or publish packages and containers.

Where a repository uses `dependabot/fetch-metadata`, the documented
`update-type` is the highest SemVer level represented by a grouped PR.
A major-containing group is therefore expected to stay excluded by the
existing `version-update:semver-major` auto-merge guard. This expectation
requires verification against each repository's actual workflow; merely
including a guard in a reference document changes no live protections.

Existing CODEOWNERS policy, required reviews, branch protection, security
checks, and test validation remain in force. A green but irrelevant
unit-test or lint result is not adequate evidence for an unexercised
release or publishing boundary. A successful auto-merge workflow step
is neither evidence of approval nor proof that GitHub merged the PR.

### Exceptions and multiple ecosystems

Repositories MAY exclude particular high-risk dependencies from the
broad group or give them independent groups when compatibility,
permissions, release authority, or test coverage justify isolation.
Exclusion from a group must not unintentionally suppress the
dependency's updates altogether.

The example covers GitHub Actions because this was the observed pilot
surface. Other package ecosystems require valid manifests, separate
configuration entries, and review of their own tests and upgrade
semantics. Neither grouping across ecosystems nor consolidation across
repositories is promised.

### No automatic installation

The reusable example is stored at:

```text
standards/examples/repository/github/dependabot.yml
```

It is non-normative, is included in the normal full standards release
archive, and materializes beneath `doc/standards/` in consuming
repositories. It SHALL NOT automatically be copied to
`.github/dependabot.yml` by a standards release adoption, upgrade,
refresh, or repair.

Adding or editing an active `.github/dependabot.yml` remains a
separate, reviewed repository action. This PR does not activate
Dependabot version updates in coding_standards itself.

## Threat and Failure Model

Relevant assets include source dependencies, GitHub Actions workflow
definitions, GitHub tokens, registry and signing credentials, release
artifacts, tags, and code-owner authorization boundaries.

- A malicious, abandoned, or incompatible upstream version can be hidden
  among several benign version changes in a single PR.
- A grouped major upgrade can introduce breaking behavior even if other
  updates are minor or patch releases.
- A test suite can pass without executing the impacted build, signing,
  release, or registry-publishing path.
- A grouping resolution failure can prevent or split a desired batch.
- Existing PRs can continue to occupy the review queue after a new
  grouping configuration is installed.
- A restrictive PR limit can suppress useful updates behind stale PRs.
- A disabled security-update feature can create an unobserved security
  maintenance gap.
- A CODEOWNERS file may exist without an effective GitHub rule
  enforcing its approval.

Mitigations are targeted dependency review, preserving action pinning,
independent security-update settings, relevant validation, explicit
major-auto-merge exclusion, effective branch protections, and iterative
portfolio measurement. None is proof of dependency provenance,
compatibility, or safety in isolation.

## Alternatives Considered

### Keep only minor and patch upgrades grouped

Rejected as the cross-repository baseline because it leaves majors as
individual PRs, sustaining review overhead. A repository may isolate
specific major versions when the actual change merits it.

### Require majors to be automatically merged too

Rejected. Grouping is about reducing duplicate proposals; it must not
expand authorization to merge potentially breaking dependency updates.

### Use monthly scheduling everywhere

Rejected as the baseline for active repositories because routine
maintenance would be delayed wholesale. Monthly cadence remains
available as an explicit lower-activity option.

### Group routine updates with security remediation

Rejected. Dependabot security updates should remain a distinct
advisory-driven path, without depending on the scheduled routine group
or the seven-day version-update cooldown.

### Limit open PRs to one or two immediately

Deferred. This may hide rather than resolve existing PRs and block
new scheduled updates until the backlog is reconciled.

### Configure every ecosystem and cross-ecosystem group upfront

Rejected. Repositories differ in manifests and compatibility surfaces.
The common example uses GitHub Actions; additional ecosystems are
locally configured after inspection.

### Auto-install Dependabot configuration with standards releases

Rejected under ADR-003 and ADR-009. Standards adoption must not
silently modify active `.github/` configuration.

### Maintain only a prose policy without an example

Rejected because a reusable, syntactically valid YAML example reduces
the chance that each repository reintroduces minor/patch-only grouping
or omits the version-updates/security-updates distinction.

## Consequences and Expected Outcomes

The standards archive gains a normative maintenance policy and a
copyable GitHub Actions Dependabot example. Repositories adopting it
may receive fewer routine dependency PRs per ecosystem. Reviewers
must inspect each dependency within a larger PR and may need to split
a broken group.

The standard does not guarantee exactly one PR per schedule, a fixed
portfolio-wide PR reduction, automatic reconciliation of existing
Dependabot PRs, safe major upgrades, enabled security alerts, or
effective GitHub review settings. Its operational effectiveness
should be measured over successive Dependabot runs and refined
through narrow exceptions.

No runtime code, active workflow, Dependabot configuration, branch
ruleset, or release archive contract changes directly in this PR.
Consumers receive the policy only through a subsequent published
standards version and a normal, pinned adoption PR.

## Compatibility and Migration

Existing repositories retain their current active configuration and
accepted local ADRs until a separate deliberate adoption. A migration
must inventory old PRs, reconcile coverage before closing superseded
proposals, preserve configured review gates, and measure subsequent
Dependabot runs.

This adds cross-cutting engineering governance to the standards
library, which may affect consumers after their next standards
adoption. It is distinct from application runtime compatibility and
must be classified under the repository's release governance.

## Relationships to Prior Decisions

- ADR-003: deterministic released standards library and explicit
  consumer adoption.
- ADR-005/006: Accepted decisions and maintained ADR landing-page digest.
- ADR-007: trustworthy test evidence and failure propagation.
- ADR-009: non-normative examples do not activate repository settings.
- ADR-010: model-generated work cannot grant itself approval authority.
- ADR-012/015: Ready handoff and auto-merge only under existing
  verified human and CI protections.
- ADR-016: an optional-presence CI gate is not evidence that every
  expected verification check executed.

[dependabot-standard]: ../../standards/general/dependabot-maintenance-standard.md
[pilot-adr]: https://github.com/wesley-dean/template-bash/blob/main/doc/adr/ADR-018-consolidated-dependabot-version-updates.md
