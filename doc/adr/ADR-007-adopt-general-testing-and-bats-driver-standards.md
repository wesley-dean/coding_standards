# ADR-007: Adopt General Testing and Bats Driver Standards

Date: 2026-09-23

## Status

Accepted

## Context

The standards library already governs coding, architecture, documentation,
repository practice, release versioning, development workflow, and ADR
maintenance, but it does not yet define a shared testing philosophy.

Several maintained repositories have independently converged on similar testing
patterns.  They use one repository-level test entry point, focus assertions on
observable behavior, exercise generated distribution artifacts, keep test
fixtures deterministic, and separate ordinary validation from external
integration boundaries.

Recent work in `routeros_ssl` exposed a second need.  That repository already
used Bats and TAP as its canonical developer-facing test stream, while GitHub
pull-request review would benefit from JUnit test-result publication.  Bats can
emit TAP to the console and JUnit XML as a report from the same execution, so
structured CI reporting does not require replacing the existing TAP contract or
running the suite twice.

That implementation also exposed a CI trust-boundary concern.  Publishing checks
and durable pull-request comments requires write permissions, while the validation
workflow executes pull-request code and should remain read-only.  A separate
privileged publication workflow can consume generated test reports and trusted
event metadata without checking out or executing untrusted code.

A related review of `bash-doxygen` showed that Bats has value beyond testing
Bash programs.  The project currently maintains a POSIX shell harness that owns
TAP numbering, failure aggregation, fixture orchestration, and diagnostics while
driving an AWK filter.  Bats supports dynamic test registration, black-box command
execution, TAP output, and JUnit reports.  Those capabilities can replace
home-grown test-driver machinery while preserving the project's existing
behavior-focused fixtures, golden outputs, diagnostic expectations, and
multi-artifact contract.

The relevant reusable insight is therefore broader than "use Bats for Bash."
Testing policy should be language-neutral, while a Bash/Bats refinement can
standardize Bats as a process-oriented driver for any subject that exposes useful
command-line or filesystem behavior.

## Decision Drivers

- Establish one reusable testing philosophy across maintained repositories.
- Keep local and CI test orchestration aligned through repository-owned entry
  points.
- Favor deterministic observable evidence over implementation-coupled tests.
- Preserve meaningful failure information across multi-artifact and
  multi-environment suites.
- Treat generated and distributed artifacts as behavior that must be tested, not
  merely built.
- Avoid turning flaky tests, arbitrary coverage percentages, or testing-pyramid
  diagrams into substitutes for engineering judgment.
- Standardize generated test-report handling without treating reports as
  maintained source.
- Preserve TAP as the canonical Bats console output while allowing JUnit
  publication from the same execution.
- Make Bats available as a black-box driver for non-Bash subjects when that
  reduces bespoke harness machinery.
- Separate untrusted validation execution from privileged GitHub publication.

## Decision

The standards library SHALL add:

```text
standards/general/testing-standard.md
standards/bash/testing-standard.md
```

The general testing standard SHALL define cross-language expectations for:

- canonical repository-level test entry points;
- deterministic and repeatable execution;
- isolation from live infrastructure by default;
- observable behavior as the preferred assertion surface;
- explicit command-line exit-status testing;
- positive and negative-path coverage;
- behavioral equivalence across public distribution artifacts;
- direct validation of generated deliverables;
- working-tree cleanliness;
- complete failure reporting with preserved aggregate status;
- flaky tests as defects;
- test independence;
- isolated fixtures and temporary state;
- intentionally small test doubles;
- security-sensitive regression coverage;
- regression tests for corrected defects;
- coverage metrics as diagnostic information rather than universal correctness
  thresholds;
- explicit test categories where execution environments differ;
- test source as maintained code;
- structured test reports as derivative state;
- `test-results/` as the conventional generated-report location;
- explicit exclusion of generated reports from broad linters and scanners,
  including MegaLinter where used;
- publication of structured test results when it materially improves review; and
- separation of privileged test-result publication from execution of potentially
  untrusted pull-request code.

The Bash testing standard SHALL refine that policy for repositories using Bats.

Bats SHALL be treated as a process-oriented behavioral-test driver rather than as
a framework that is only appropriate when the implementation language is Bash.
A Bats suite MAY drive Bash, AWK, Python, JavaScript, compiled executables,
Doxygen, container entry points, or other subjects whose contract can be observed
through process status, output, argv, generated files, or filesystem effects.

For Bats-based repositories, TAP SHOULD remain the canonical console and CI log
format unless repository-specific governance establishes otherwise.  When JUnit
reporting is desired, Bats SHOULD emit JUnit from the same execution through its
report formatter rather than run the suite a second time solely for reporting.

Bats SHOULD own framework concerns such as test registration, TAP serialization,
failure bookkeeping, and JUnit generation.  Existing domain-specific fixtures,
golden files, normalizers, fakes, and semantic helper functions SHOULD be
preserved when they continue to express useful behavior.  Migration from a
bespoke harness to Bats does not imply rewriting the underlying testing model.

Repositories with fixture or artifact matrices SHOULD consider
`bats_test_function` dynamic registration so each matrix element becomes a
first-class named Bats test and therefore a first-class TAP/JUnit result.

The standards library SHALL include a small non-normative example beneath:

```text
standards/examples/bash/testing/example.bats
```

to demonstrate dynamic registration across several behaviorally equivalent
command-line artifacts.

## CI Reporting and Trust Boundary

Generated structured reports SHALL remain derivative state.  Repositories using
the standard `test-results/` convention SHOULD ignore that directory in Git,
remove it through appropriate cleanup, and explicitly exclude it from broad
linting or scanning surfaces.

When GitHub Actions publication requires write permissions, a workflow that
executes pull-request code SHOULD remain read-only whenever practical.

The preferred model separates:

1. a read-only validation workflow that executes repository or pull-request code,
   runs tests, generates reports, and uploads artifacts; and
2. a privileged publisher triggered from trusted workflow context that downloads
   report artifacts, does not check out or execute pull-request code, and receives
   only the write permissions required to publish checks or pull-request
   feedback.

If the privileged publisher needs the original GitHub event payload to associate
results with a pull request, that metadata SHOULD be preserved by a no-checkout
job that does not execute repository or pull-request code.

The standard describes this security boundary rather than requiring one specific
third-party publishing action.

## Alternatives Considered

### Add only JUnit publication guidance

Rejected because the reporting question exposed broader recurring testing
decisions across repositories.  A narrow JUnit document would standardize an
output format without establishing what constitutes trustworthy test evidence,
how artifacts should be exercised, how failures should be aggregated, or how
test code should be maintained.

### Put all testing guidance in one Bash standard

Rejected because most of the desired rules are language-neutral.  Determinism,
observable behavior, artifact equivalence, flaky-test handling, generated-report
state, CI trust boundaries, and regression policy apply equally to Python,
JavaScript, AWK, compiled programs, and other systems.

### Put Bats guidance in the general standard

Rejected because TAP, Bats report formatters, `run`, PATH-injected command
fakes, and `bats_test_function` are framework-specific mechanics.  Keeping them
in a Bash/Bats refinement allows the general standard to remain useful when a
project uses pytest, Jest, PHPUnit, or another test framework.

### Treat Bats as Bash-only

Rejected because the framework drives processes and filesystem-visible effects.
The implementation language of the subject does not determine whether Bats can
exercise its observable contract.  Projects such as documentation filters can
benefit from Bats even when the maintained implementation is AWK or another
language.

### Require Bats for all command-line projects

Rejected because framework adoption has a dependency and migration cost.  A
small existing harness may remain appropriate when Bats would not reduce
complexity or improve evidence quality.  The Bash standard therefore describes
when Bats is useful rather than universally mandating it.

### Replace TAP with JUnit

Rejected because JUnit primarily serves structured reporting, while TAP remains
a strong developer-facing and automation-readable console stream for Bats.
Generating both from one execution preserves the established local interface and
avoids unnecessary duplicate runs.

### Run tests twice to generate two formats

Rejected because Bats already separates console and report formatters.  Running
the suite twice increases cost and can produce two reports describing different
executions.

### Publish test results from the code-executing validation job

Rejected because checks and pull-request comments commonly require write
permissions.  Granting those permissions to a job that executes untrusted
pull-request code weakens the security boundary merely for presentation.

### Establish universal coverage thresholds

Rejected because line or branch coverage is useful diagnostic information but is
not proof that important behavior is correct.  Risk-based cases and observable
contracts are more durable shared governance than one arbitrary percentage.

### Require one testing pyramid

Rejected because repositories vary in architecture, risk, deployment model, and
integration boundaries.  The standard distinguishes test categories when useful
without requiring a fixed ratio among them.

## Consequences

### Positive

- Consuming repositories gain one shared language-neutral testing philosophy.
- Test commands and CI workflows are encouraged to use the same repository-owned
  orchestration boundary.
- Behavioral tests focus on user-visible contracts rather than private helper
  structure.
- Generated and transformed artifacts receive explicit behavioral validation.
- Multi-artifact failures can remain visible in one run without weakening the
  final test gate.
- Generated reports have a predictable disposable location and are kept away from
  source-oriented linting and scanning.
- Bats repositories can produce TAP and JUnit from one execution.
- Projects with custom TAP serializers can evaluate deleting framework-like
  harness code while preserving domain fixtures.
- Non-Bash CLI projects can adopt Bats when it is a good black-box driver.
- GitHub result publication can improve PR review without granting write
  permissions to untrusted validation execution.

### Negative

- Bats is an additional dependency for repositories that choose to adopt it.
- Existing test harnesses may require migration work before they can benefit from
  framework-managed JUnit output.
- A separate privileged publication workflow introduces additional CI
  configuration.
- Maintaining both a general standard and a Bats refinement requires contributors
  to decide which rules are universal and which are framework-specific.
- Dynamic registration is powerful but less familiar than hand-written Bats
  tests and requires careful review when used.

## Compatibility and Migration

Existing consuming repositories are unaffected until they adopt a release that
contains these standards.

Because every standards release contains the complete library, the presence of
the Bash testing standard does not make Bats applicable to every consumer.
Applicability depends on whether the repository uses Bats or explicitly adopts
that refinement.

Repositories with accepted local testing ADRs remain governed by those local
decisions when they explicitly refine or supersede shared guidance.

A repository migrating an existing Bats suite can adopt the TAP/JUnit and
generated-report rules incrementally.

A repository migrating a bespoke shell TAP harness SHOULD preserve proven
fixtures, golden outputs, diagnostic expectations, and artifact matrices unless a
separate reason exists to change them.  The first migration step may replace only
test registration, assertion bookkeeping, TAP serialization, and report
generation with Bats.

For example, `bash-doxygen` currently has accepted local governance favoring a
POSIX shell TAP harness and explicitly rejecting Bats under the conditions that
existed when that decision was made.  Adopting this standards release would not
silently override that ADR.  A future `bash-doxygen` change would need a local
ADR that records why the dependency tradeoff changed and which portions of the
earlier fixture and TAP contract remain governing.

The change is released as a new standards capability.  Under the repository's
Conventional Commit and Semantic Versioning governance, the pull request is
intended to merge with a `feat:` integration commit so the next release receives
a minor-version increment from the current release line.

## Expected Outcome

A maintainer or coding agent can consult the general testing standard to design or
review tests without first choosing a framework.  When Bats is appropriate, the
Bash refinement provides a common vocabulary for TAP output, JUnit reporting,
dynamic matrix registration, command fakes, artifact injection, and black-box
testing of both Bash and non-Bash subjects.

Projects gain more consistent test evidence and richer pull-request feedback
without conflating reporting with validation or weakening CI security boundaries.

## Related Decisions

- ADR-003 governs release artifacts and explicit consumer adoption.
- ADR-005 governs ADR acceptance semantics.
- ADR-006 governs the current-decision landing page.

## Related Work

- coding_standards issue #13 records the testing-standard requirements.
- routeros_ssl issue #119 and pull request #120 provide the first concrete
  TAP/JUnit and privileged-publication implementation that informed this
  standard.
