# AI Safety Standard

## Status

Recommended engineering standard

## Purpose

This standard defines reusable safety expectations for engineering work that uses
large language models, AI assistants, coding agents, review agents, model-generated
content, or other probabilistic AI systems.

The primary concern is ordinary model fallibility.  An AI system may misunderstand
intent, omit important context, hallucinate facts or interfaces, make an incorrect
inference, rely on stale information, misread tool output, or produce a plausible
but incorrect result.

The governing principle is:

> AI-generated output is a proposal or interpretation until supported by evidence
> appropriate to its intended use.

## Applicability

This standard applies when AI materially contributes to source code, tests,
documentation, architecture, repository review, operational analysis, tool
selection, generated configuration, release or deployment decisions, security
analysis, or other engineering work whose correctness matters.

It applies to interactive assistance and automated or semi-automated agents.

Repository-specific ADRs or explicit policy MAY refine this standard.  Such
refinements MUST NOT silently weaken its central principles of verification,
visible uncertainty, constrained authority, and deterministic mediation of
consequential side effects.

## Non-Goals

This standard does not assume that an AI system is malicious, self-directed, or
intentionally attempting harm.

It does not attempt to govern speculative catastrophic-AI scenarios.

Its focus is more ordinary and practical: a model can be confidently, fluently,
and consequentially wrong.

Security concerns such as prompt injection, credentials, identity, least
capability, and trust boundaries remain governed primarily by the general security
corpus.

## Normative Language

The terms MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative requirements.

## Core Safety Model

A safe AI-assisted workflow SHOULD separate:

1. **reasoning**, where the AI proposes, interprets, compares, or recommends;
2. **evidence**, where material claims are checked;
3. **authorization**, where policy determines whether an action is permitted; and
4. **execution**, where deterministic code performs the consequential operation.

These layers MAY exist in one application, but their responsibilities SHOULD
remain distinguishable.

Fluency is not evidence.

Model confidence is not evidence.

Agreement from another model is not necessarily independent evidence.

A plausible result MUST NOT be treated as verified merely because it is detailed,
confident, or internally consistent.

## Epistemic Vocabulary

AI-assisted work SHOULD distinguish among the following when the distinction
materially affects correctness or review.

### Observation

An observation is information obtained directly from an inspected source, tool,
file, command result, API response, repository state, test run, or other observable
artifact.

An AI MUST NOT represent an inference as an observation.

### Source-Supported Fact

A source-supported fact is a claim directly supported by a relevant source.

The source SHOULD be identifiable when the claim materially affects architecture,
compatibility, security, release behavior, or another consequential decision.

### Inference

An inference is a conclusion drawn from observations or source-supported facts.

An inference SHOULD remain distinguishable from the evidence on which it depends.

### Assumption

An assumption is a condition accepted temporarily so work can proceed.

Material assumptions SHOULD be stated explicitly and SHOULD be verified before
they control consequential or difficult-to-reverse actions.

### Hypothesis

A hypothesis is a proposition being investigated rather than an established
conclusion.

### Recommendation

A recommendation is advice based on evidence, constraints, tradeoffs, or judgment.

A recommendation SHOULD NOT be phrased as fact merely because the model strongly
prefers it.

### Unknown or Uncertain

Unknown information MUST NOT be replaced with plausible invention.

Uncertainty SHOULD be stated at the level needed for a human or downstream
component to make an informed decision.

## Do Not Manufacture Evidence

An AI system MUST NOT claim that an observation, verification, test, command,
review, fetch, build, source inspection, or other evidence-producing action
occurred when it did not occur.

Examples include:

- claiming tests passed when they were not run;
- claiming a file was inspected when it was not read;
- inventing command output;
- inventing repository state;
- inventing issues, pull requests, commits, releases, or workflow results;
- inventing APIs, functions, options, configuration keys, or file paths;
- fabricating citations or source references;
- attributing rationale to maintainers without evidence; and
- claiming a generated artifact was verified when only its source was inspected.

When direct evidence is unavailable, the correct state is uncertainty.

## Source Grounding

Consequential claims SHOULD be grounded in relevant source material.

Where practical, prefer current repository state, governing repository
documentation and ADRs, primary technical documentation, executable evidence, and
direct tool observations over plausible reconstruction.

An AI system SHOULD verify that a source actually supports the claim for which it
is cited.

Repository governance SHOULD be reviewed before making changes that affect
architecture, compatibility, security boundaries, release behavior, public
interfaces, or other governed contracts.

## Current State and Freshness

When correctness materially depends on state that can change, that state SHOULD be
observed rather than remembered.

Examples include:

- current branch and repository contents;
- issue or pull-request state;
- workflow results;
- dependency and released versions;
- external documentation;
- service behavior; and
- environment configuration.

Cached context, summaries, memory, prior conversation, or earlier tool results MAY
orient the work but SHOULD NOT substitute for current observation when state may
have changed.

Absence from current model context MUST NOT be treated as evidence that something
does not exist.

## Context Limitations

AI systems may operate with incomplete, truncated, summarized, or stale context.

Before consequential work, the system SHOULD retrieve the governing or source
material on which correctness depends.

Long-running work SHOULD preserve important constraints explicitly enough that
they can be revalidated after context reduction or handoff.

A summary or memory SHOULD be treated as an aid rather than an infallible
reproduction of the original source.

## Assumptions and Error Propagation

An incorrect early premise can contaminate a long chain of otherwise coherent
reasoning.

Material assumptions SHOULD therefore remain identifiable.

When new evidence invalidates or materially changes an upstream premise,
conclusions that depend on that premise SHOULD be reconsidered.

A workflow SHOULD avoid circular validation in which one AI-generated artifact is
used as the sole evidence that another AI-generated artifact is correct.

## Verification Proportional to Consequence

Verification depth SHOULD increase with consequence and uncertainty.

Relevant factors include:

- reversibility;
- privilege;
- external visibility;
- security impact;
- compatibility impact;
- data sensitivity;
- blast radius;
- cost of failure; and
- ambiguity.

Low-risk, easily reversible assistance MAY rely on lightweight review.

Consequential, privileged, externally visible, security-sensitive, or
difficult-to-reverse actions SHOULD require stronger evidence before execution.

Verification MAY include reading source, consulting governing ADRs, running tests,
compiling or syntax-checking, validating generated artifacts, querying the current
API or service, checking authoritative documentation, inspecting the final diff,
static analysis, deterministic checks, and human domain review.

## Independent Evidence

Evidence SHOULD be independent of the failure mode it is intended to detect.

Examples include:

- a compiler detecting syntax or type errors;
- a test suite detecting behavioral regressions;
- a repository fetch correcting stale model memory;
- an ADR correcting an architectural assumption;
- a generated-artifact test detecting transformation errors;
- a deterministic schema validator rejecting malformed model output; and
- a human reviewer evaluating product, legal, ethical, or organizational judgment.

Asking the same model to reconsider its answer MAY improve reasoning but SHOULD
NOT be treated as independent verification.

Agreement between multiple models MAY provide perspective but MUST NOT be
represented as proof when shared failure modes remain plausible.

## Tool Use and Observation

A workflow SHOULD distinguish:

- what the model believes;
- what the model requested;
- what a tool actually did;
- what the tool returned; and
- what conclusion that evidence supports.

Tool success usually establishes a narrow property.

A successful file write proves that a write completed, not that the content is
correct.  A successful build proves that the build completed, not that behavior is
correct.  A passing test establishes only the behavior exercised by that test.  A
successful HTTP request proves that a response was received, not that its contents
are trustworthy.

## Deterministic Mediation of Side Effects

AI reasoning components SHOULD NOT directly own broad side-effecting capabilities
when deterministic code can mediate those effects.

The preferred flow is:

```text
AI reasoning
    |
    v
structured proposal or request
    |
    v
deterministic policy and validation
    |
    v
deterministic side effect
    |
    v
result returned as data
```

The AI may decide what it wants to request.  Deterministic code decides whether
the request is allowed, whether its inputs satisfy required invariants, and how
the side effect is performed.

### Reasoning Authority, Execution Authority, and Authorization

These concepts MUST remain distinct.

- **Reasoning authority** means the AI may recommend or request an action.
- **Execution authority** means a component has the technical capability to
  perform an action.
- **Authorization** means policy permits the action in the current context.

The ability to request an operation MUST NOT grant the capability or authorization
to perform it.

### Network Access

AI reasoning components SHOULD NOT possess general network capability.

When network access is required, a deterministic network mediator SHOULD perform
the request and constrain, as applicable:

- protocol;
- destination host and port;
- path;
- operation or HTTP method;
- redirects;
- request and response sizes;
- timeout;
- authentication;
- TLS validation; and
- allowed response handling.

The AI SHOULD receive retrieved data rather than unrestricted socket or HTTP
client capability.

### Filesystem Reads

AI reasoning components SHOULD NOT receive unrestricted filesystem read access
when a narrower deterministic interface can provide the required data.

A filesystem mediator SHOULD constrain, as applicable:

- allowed roots;
- path normalization and traversal;
- symbolic links;
- file type;
- file size;
- encoding;
- device or special files; and
- sensitive locations.

### Filesystem Writes

AI reasoning components SHOULD NOT possess unrestricted filesystem write access.

When AI-assisted work requires mutation, deterministic code SHOULD mediate the
operation.

Preferred patterns include proposing a patch, proposing replacement content for a
known file, requesting creation beneath an approved root, or requesting a named
repository operation.

The mediator SHOULD enforce allowed roots, constrained targets, traversal
prevention, symbolic-link policy, overwrite policy, size limits, permissions,
working-tree scope, and post-write verification as applicable.

### Command and Process Execution

AI reasoning components SHOULD NOT receive unrestricted shell execution when a
narrow deterministic executor can perform the required operations.

A deterministic executor SHOULD prefer named operations, fixed executables,
explicit argument vectors, constrained working directories, minimal environment,
timeouts, resource limits, controlled output, and explicit exit-status handling.

AI-generated or externally influenced text SHOULD NOT be interpolated into an
arbitrary shell command when a structured operation can express the same intent.

### Credentials

AI reasoning components SHOULD NOT receive credentials merely because a
downstream deterministic component requires them.

Credentials SHOULD remain within the narrowest component that performs the
authorized operation.

The AI MAY request an operation requiring a credential without receiving, reading,
logging, or reproducing that credential.

### External Mutation

Publication, deployment, merge, release, account mutation, infrastructure change,
repository mutation, and similar consequential effects SHOULD be performed by
deterministic components that independently validate and authorize the request.

The AI SHOULD provide structured intent rather than unrestricted mutation
authority.

### Capability Expansion

An AI component MUST NOT be able to broaden its own filesystem, network, process,
credential, API, or mutation capabilities merely by requesting them.

Capability changes SHOULD require governance or mediation outside the AI reasoning
component.

## Fail Closed on Invalid Requests

A deterministic mediator SHOULD reject unsupported, ambiguous, malformed, or
unauthorized consequential requests rather than guessing the model's intent.

If a required invariant cannot be established, the operation SHOULD fail closed.

Error messages MAY provide enough structured information for the AI to revise its
proposal without granting broader authority.

## Structured Interfaces

AI-to-tool interfaces SHOULD prefer structured schemas over free-form executable
text when practical.

Schema validation is evidence that a request has an expected shape.  It does not
replace authorization, semantic validation, or destination-specific checks.

## Scope and Reversibility

AI-assisted changes SHOULD favor narrow scope, small blast radius, explicit
targets, reversible operations, inspectable diffs, and clear recovery paths.

The AI SHOULD NOT introduce unrelated cleanup, architectural change, dependency
updates, or expanded scope merely because those changes appear beneficial.

When material scope is ambiguous, follow the repository's Development Workflow
Governance.

Destructive or difficult-to-reverse operations SHOULD receive stronger validation
and, where appropriate, human approval.

## Human Oversight

Human review SHOULD be proportional to consequence rather than required for every
AI-assisted action.

Human judgment is especially important when a decision depends on product intent,
organizational priorities, legal interpretation, ethical judgment, acceptance of
residual risk, architectural tradeoffs, compatibility policy, irreversible
consequences, or unresolved ambiguity.

Human approval MUST NOT be treated as proof that a technical control is correct.

Deterministic containment SHOULD complement rather than be replaced by human
oversight where practical.

## AI-Generated Code and Documentation

AI-generated code is maintained code and MUST satisfy the same applicable coding,
architecture, documentation, compatibility, testing, security, and review
standards as human-written code.

AI-generated documentation is maintained documentation when committed or
published.

Generated documentation SHOULD be checked against actual behavior, governing ADRs,
public interfaces, and source material.

A generated summary MUST NOT silently change the meaning of the authoritative
source it summarizes.

## Testing AI-Assisted Work

AI-assisted changes SHOULD receive the same project-owned test and verification
process as equivalent human-authored changes.

Additional evidence MAY be warranted when the model influences a consequential
boundary.

Relevant checks MAY include regression tests, negative tests, generated-artifact
tests, static analysis, schema validation, adversarial inputs, diff-scope review,
governance review, mediator tests, and tests demonstrating that unsupported
capability requests are rejected.

Passing tests remain scoped evidence rather than proof of complete correctness.

## Testing Deterministic Mediators

Deterministic mediators SHOULD receive direct automated tests when they protect
material side effects.

Tests SHOULD cover, as applicable:

- allowed requests;
- rejected operation types;
- malformed requests;
- unauthorized targets;
- traversal attempts;
- disallowed network destinations;
- command argument boundaries;
- missing authorization;
- size and resource limits;
- timeout behavior;
- symbolic-link or path edge cases;
- partial failure;
- fail-closed behavior; and
- audit output that avoids secret disclosure.

The model itself does not need to behave deterministically for these controls to
be tested deterministically.

## Disclosure and Handoff

Consequential AI-assisted work SHOULD preserve enough context for another human or
agent to understand what was established and what remains uncertain.

Where material, preserve assumptions, authoritative sources consulted,
observations, verification performed, tests actually run, limitations, unresolved
uncertainty, relevant human decisions, known risks, and deferred follow-up work.

Routine low-risk assistance does not require an exhaustive process transcript.

The purpose is to preserve decision-relevant evidence, not to archive every token
of model reasoning.

## Relationship to Security Standards

This standard and the security corpus are complementary.

This standard focuses on model fallibility, epistemic discipline, verification,
uncertainty, mediated execution, and the safe conversion of AI recommendations
into effects.

The security corpus remains authoritative for identity, authorization, taint,
least capability, credentials, trust boundaries, source-to-sink validation,
containment, threat modeling, evidence, and residual risk.

AI workflows that cross security-sensitive boundaries MUST follow the applicable
security standards.

Relevant security commandments include SEC-01, SEC-02, SEC-03, SEC-04, SEC-05,
SEC-06, SEC-07, SEC-09, SEC-10, SEC-11, and SEC-12.

## Relationship to Development Workflow

Development Workflow Governance remains authoritative for task scope, backlog
capture, ambiguity, commits, pull requests, review readiness, and scope control.

AI assistance MUST NOT be used as a reason to bypass those controls.

## Relationship to Testing

The General Testing Standard remains authoritative for test architecture,
determinism, public artifact verification, CI result publication, and evidence
semantics.

This standard adds AI-specific guidance about what should be verified and how
model-generated conclusions should relate to evidence.

## Review Checklist

Before relying on AI-assisted work for a material engineering outcome, review as
applicable:

- [ ] Observations are distinguishable from inferences and assumptions.
- [ ] Material claims are grounded in current or authoritative evidence.
- [ ] No evidence-producing action is claimed unless it actually occurred.
- [ ] Unknown information has not been replaced with plausible invention.
- [ ] Current state was refreshed where correctness depends on freshness.
- [ ] Material assumptions are visible and verified where consequence warrants.
- [ ] Dependent conclusions were revisited when upstream premises changed.
- [ ] Verification depth is proportional to consequence and uncertainty.
- [ ] Evidence is reasonably independent of the failure mode it should detect.
- [ ] Tool output is interpreted only as broadly as the result supports.
- [ ] Broad network access is absent where deterministic mediation is practical.
- [ ] Broad filesystem access is absent where deterministic mediation is practical.
- [ ] Arbitrary shell execution is absent where named operations can express the work.
- [ ] Credentials remain outside the reasoning component where practical.
- [ ] External mutation crosses deterministic validation and authorization.
- [ ] The AI cannot broaden its own capabilities.
- [ ] Invalid or ambiguous consequential requests fail closed.
- [ ] Changes remain narrow, reviewable, and reversible where practical.
- [ ] Human review is present where human judgment is required.
- [ ] AI-generated code and documentation meet normal project standards.
- [ ] Tests and deterministic checks provide scoped evidence for material claims.
- [ ] Material uncertainty, limitations, and residual risk remain visible.

## Governing Principle

AI systems are useful reasoning tools and unreliable authorities.

Use them to propose, interpret, compare, and assist.  Require evidence for material
claims.  Keep consequential side effects behind deterministic validation and
authorization boundaries.  Make uncertainty visible, keep authority narrow, and
design workflows so that a plausible mistake does not silently become a
consequential one.
