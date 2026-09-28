# ADR-010: Adopt an AI Safety Standard Focused on Model Fallibility

Date: 2026-09-28

## Status

Accepted

## Context

The standards library increasingly assumes that AI systems may assist with
software development, review, documentation, analysis, planning, and repository
work.

Existing governance already addresses adjacent concerns.  Development Workflow
Governance constrains scope, ambiguity, commits, pull requests, and backlog
management.  The General Testing Standard defines executable evidence and warns
against overclaiming what tests establish.  ADR-008 and the security corpus govern
zero trust, tainted input, least capability, identity, authorization, source-to-
sink validation, containment, and disclosure.

Those standards do not yet provide one explicit model for a recurring AI-specific
engineering risk: a model may produce output that is plausible, fluent, internally
consistent, and wrong.

Relevant failure modes include hallucinated interfaces, stale repository state,
incorrect inference, omitted constraints, fabricated verification claims,
misunderstood intent, false certainty, context truncation, misread tool output,
incorrect summaries, and propagation of an early mistaken premise through a long
workflow.

The same problem becomes more consequential when AI reasoning is coupled directly
to broad network, filesystem, shell, credential, publication, deployment, or
external-mutation capability.

The repository therefore needs a cross-cutting AI safety standard focused on
model fallibility, evidence, uncertainty, and safe conversion of AI proposals into
consequential effects.

## Decision Drivers

- Treat ordinary model fallibility as the primary AI safety concern.
- Distinguish observation, source-supported fact, inference, assumption,
  hypothesis, recommendation, and uncertainty.
- Prohibit fabricated claims of verification or observation.
- Prefer current and authoritative evidence over plausible reconstruction.
- Make verification proportional to consequence and uncertainty.
- Prevent stale or truncated context from silently becoming authoritative.
- Preserve evidence completeness, truncation, provenance, and retrieval failure where material.
- Re-evaluate dependent conclusions when an upstream premise changes.
- Treat persisted or cached AI output as untrusted historical judgment rather than authority.
- Distinguish deterministic equivalence from semantic correctness.
- Keep AI reasoning distinct from authorization and execution authority.
- Prefer deterministic mediation for network, filesystem, process, credential,
  publication, deployment, and other consequential side effects.
- Express AI-requested effects through narrow semantic operations rather than
  unnecessarily broad destructive primitives.
- Validate material mutation preconditions, postconditions, and resulting diffs.
- Treat behavioral instructions as guidance rather than enforcement of technical
  safety properties.
- Make prohibited capabilities structural properties of process, dependency, and runtime boundaries where practical.
- Keep AI capabilities narrow and prevent self-expansion of authority.
- Prefer deterministic persistence of AI-derived durable state.
- Revalidate mutable live state immediately before consequential mutation.
- Keep evidence-plane content from acquiring control-plane authority.
- Treat AI confidence as advisory unless independently calibrated, and never as a substitute for hard gates.
- Preserve existing ownership boundaries in the security, testing, workflow, and
  ADR standards.
- Keep human review proportional rather than requiring a person for every
  low-risk AI-assisted action.
- Provide practical guidance usable by both interactive assistants and automated
  agents.

## Decision

The standards library SHALL add:

~~~text
standards/general/ai/
└── safety-standard.md
~~~

The standard SHALL remain cross-language and SHALL apply to interactive AI
assistants, coding agents, review agents, AI-generated content, and automated
workflows where model output materially influences engineering decisions or
effects.

The standards library SHALL also add:

~~~text
standards/examples/general/ai/
└── safety.md
~~~

as a non-normative worked-example document.

### Model Fallibility

The standard SHALL treat AI output as fallible.

Fluency, detail, internal consistency, model confidence, or repeated model
agreement SHALL NOT substitute for evidence appropriate to the intended use.

Unknown information SHALL NOT be replaced with plausible invention.

An inference SHALL NOT be represented as a direct observation.

An AI system SHALL NOT claim that a test, tool action, source inspection,
verification step, build, fetch, or other evidence-producing action occurred when
it did not occur.

### Epistemic Discipline

The standard SHALL distinguish observation, source-supported fact, inference,
assumption, hypothesis, recommendation, and uncertainty when those distinctions
materially affect engineering decisions.

Consequential claims SHOULD be grounded in current repository state, governing
documentation, primary technical sources, executable evidence, or direct tool
observations as appropriate.

When correctness depends materially on state that can change, current state SHOULD
be observed rather than remembered.

### Verification

Verification depth SHALL follow consequence and uncertainty rather than a
universal checklist.

High-consequence, privileged, externally visible, security-sensitive, or
difficult-to-reverse actions SHOULD require stronger evidence before execution.

Evidence SHOULD be reasonably independent of the failure mode it is intended to
detect.

Model self-review or multi-model agreement MAY provide perspective but SHALL NOT
be represented as independent proof when common failure modes remain plausible.

### Error Propagation

Material assumptions SHOULD remain identifiable.

When new evidence invalidates or materially changes an upstream premise,
conclusions that depend on that premise SHOULD be re-evaluated.

AI-generated artifacts SHOULD NOT form circular evidence chains in which generated
material is the sole proof of other generated material.

### Deterministic Mediation

AI reasoning components SHOULD NOT directly own broad side-effecting capabilities
when deterministic code can mediate the required operation.

The preferred architecture SHALL distinguish:

1. reasoning authority;
2. execution authority; and
3. authorization.

An AI's ability to request an operation SHALL NOT grant the technical capability
or policy authorization to perform it.

Behavioral instructions to the model SHALL NOT be treated as enforcement of a
safety property when violation could have material consequences.  Technical
capability boundaries, validation, authorization, or deterministic mediation
SHOULD enforce those properties outside the AI reasoning component.

AI-facing operations SHOULD express semantic intent at the narrowest practical
level.  When a narrow semantic operation can express a requested effect, the AI
SHALL NOT require a broader destructive primitive solely for convenience.

### Network Capability

AI reasoning components SHALL NOT initiate arbitrary network connections directly.

When network access is required, deterministic mediation SHOULD constrain
protocol, destination, method, authentication, TLS validation, redirects, timeouts,
sizes, and other relevant request properties before returning the result to the AI
as data.

### Filesystem Capability

AI reasoning components SHALL NOT possess unrestricted filesystem access when
narrower deterministic interfaces can provide the required read or mutation.

Filesystem mediation SHOULD constrain allowed roots, target paths, traversal,
symbolic links, file types, sizes, overwrite behavior, permissions, and other
relevant filesystem properties.

Filesystem mutations SHOULD use semantic operations, validated patches, or other
narrow requests rather than arbitrary shell redirection or whole-file replacement
when a narrower operation can express the intent.

Material filesystem mutations SHOULD carry preconditions that establish expected
current state and postconditions that verify the requested outcome.

Repository mutations SHOULD validate the resulting diff before commit,
publication, merge, deployment, or other consequential use.

### Process Capability

AI reasoning components SHALL NOT receive unrestricted shell execution when named
deterministic operations or constrained executors can express the required work.

Deterministic execution SHOULD prefer fixed executables, explicit argument vectors,
constrained working directories, minimal environment, timeouts, resource limits,
and explicit exit-status handling.

General-purpose destructive primitives SHOULD remain behind deterministic
interfaces when narrower semantic operations are available.

### Credentials and External Mutation

Credentials SHOULD remain in the narrowest deterministic component that requires
them.

An AI MAY request an operation requiring credentials without receiving the
credential itself.

Publication, deployment, merge, release, repository mutation, infrastructure
change, account mutation, and similar consequential effects SHOULD cross
deterministic validation and authorization boundaries.

Successful execution of the low-level operation SHALL NOT by itself be treated as
proof that the requested semantic transformation was correct.

### Capability Expansion

An AI component SHALL NOT be able to broaden its own filesystem, network, process,
credential, API, or mutation capabilities merely by requesting them.

Capability changes SHOULD require policy or governance outside the AI reasoning
component.

### AI Output, Reuse, and Durable State

AI-generated output SHALL remain untrusted after persistence, caching, transfer,
or reuse.

A deterministic fingerprint or exact structural match MAY establish that a prior
AI judgment applies to equivalent conditions.  It SHALL NOT establish that the
prior semantic judgment was correct.

Reusable judgments SHOULD preserve provenance, source evidence, evaluator and
policy versions, uncertainty, and independent-review status where applicable.

Durable AI-derived knowledge or cache state SHOULD be persisted by deterministic
code after validation rather than written directly by the AI-bearing component
when practical.

### Evidence Completeness and Control Authority

Material evidence SHOULD preserve completeness, truncation, provenance, and
retrieval-failure metadata.

Incomplete evidence SHALL NOT be silently represented as complete.

Content supplied for analysis SHALL remain evidence and SHALL NOT acquire
control-plane authority merely because it contains imperative language,
configuration-like syntax, or tool requests.

### Structural Capability Boundaries

When a capability is prohibited for an AI-bearing component, the implementation
SHOULD exclude it structurally through process, dependency, runtime, operating
system, mount, credential, or equivalent boundaries rather than rely only on
runtime intent.

AI-facing output interfaces SHOULD expose semantic operations rather than generic
storage or transport primitives when practical.

### Fresh-State Revalidation

Consequential mutations SHALL NOT rely solely on mutable state captured during an
earlier reasoning phase.

Deterministic code SHOULD revalidate live preconditions such as object identity,
head SHA, checks, authorization, expected prior state, and policy version
immediately before mutation.

### Confidence and Hard Gates

AI-generated confidence SHALL remain advisory unless it has been demonstrated to
be calibrated for the specific use.

Confidence SHALL NOT override deterministic policy gates, missing evidence,
authorization requirements, stale-state checks, or blocking findings.

### Human Oversight

Human review SHALL be proportional to consequence.

The standard SHALL preserve human accountability for decisions that materially
depend on product intent, organizational policy, legal or ethical judgment,
acceptance of residual risk, architecture tradeoffs, compatibility policy, or
other non-mechanical judgment.

Human approval SHALL NOT substitute for deterministic technical controls where
those controls are practical.

### AI-Generated Maintained Content

AI-generated source code, tests, configuration, and documentation SHALL satisfy
the same applicable standards as equivalent human-authored maintained content.

AI origin SHALL NOT reduce required verification.

### Relationship to Existing Standards

The AI safety standard SHALL complement rather than duplicate the existing
security, testing, development-workflow, and ADR standards.

The security corpus remains authoritative for identity, authorization, taint,
least capability, trust boundaries, credential handling, security testing, and
residual risk.

The General Testing Standard remains authoritative for test architecture and
evidence semantics.

Development Workflow Governance remains authoritative for task scope, ambiguity,
commits, pull requests, and backlog discipline.

## Placement

The standard belongs beneath `standards/general/ai/` rather than
`standards/general/security/`.

The dominant concern is broader than security.  Incorrect model reasoning can
cause defects in documentation, architecture, compatibility, maintenance, testing,
product behavior, or operations even when no attacker or security boundary is
involved.

Security remains an important consequence domain and is referenced explicitly
where AI-assisted workflows cross security-sensitive boundaries.

## Alternatives Considered

### Put AI safety under the security namespace

Rejected because model fallibility is not exclusively a security concern.
Hallucinated APIs, incorrect documentation, stale context, false verification
claims, and mistaken architecture can cause serious engineering failures without
constituting security vulnerabilities.

### Focus the standard primarily on malicious AI behavior

Rejected because the practical risk addressed by this repository is ordinary
model fallibility rather than speculative intentional hostility.

A model can cause consequential errors while behaving exactly as designed.

### Rely on human review for every AI action

Rejected because universal human gating would make low-risk assistance needlessly
expensive and would encourage ceremonial approval.

Human review should follow consequence, while deterministic controls should
enforce technical boundaries where practical.

### Give the AI direct tools and rely on prompt instructions

Rejected as the preferred architecture for consequential operations.

Prompt instructions are useful behavioral guidance but are weaker than technical
capability boundaries.  Deterministic mediation can reject invalid, unauthorized,
or out-of-scope requests even when the model misunderstands instructions.

### Allow broad capabilities but audit them afterward

Rejected as the normal model because detection after the fact does not prevent
irreversible or externally visible effects.

Auditability remains valuable, but prevention through constrained capability and
validation is preferred when practical.

### Require every AI interaction to produce a detailed evidence log

Rejected because routine low-risk assistance does not justify exhaustive process
logging.

The standard instead requires preservation of decision-relevant evidence,
assumptions, limitations, and uncertainty when consequence warrants it.

### Introduce stable AI commandment identifiers immediately

Rejected for the initial standard.

The security commandments solve a reference-consumption problem across a
multi-document security corpus.  One AI safety standard does not yet justify a
second commandment namespace.  Stable identifiers may be added later if the AI
corpus grows enough to benefit from them.

## Consequences

### Positive

- AI-assisted work gains an explicit safety model centered on realistic model
  failure modes.
- Humans and agents gain shared vocabulary for observation, inference, assumption,
  recommendation, and uncertainty.
- Fabricated verification claims are explicitly prohibited.
- Current-state checks become a first-class safeguard against stale model context.
- Verification follows consequence rather than ceremony.
- Error propagation from an incorrect early premise becomes an explicit review
  concern.
- Persisted or cached AI output does not silently gain authority.
- Exact cache or fingerprint matches can support reuse without being mistaken for
  independent proof of correctness.
- Evidence completeness and truncation become explicit parts of AI reasoning inputs.
- Structural process and dependency boundaries reinforce capability restrictions.
- Durable AI-derived state can be validated mechanically before persistence.
- Mutable state is revalidated immediately before consequential mutation.
- Evidence-plane content remains unable to redefine control-plane policy.
- Confidence scores remain subordinate to deterministic hard gates.
- AI reasoning can remain useful while deterministic code controls consequential
  side effects.
- Broad network, filesystem, shell, credential, and mutation capability is
  discouraged in favor of narrow mediated interfaces.
- Semantic operations reduce the chance that a mistaken implementation primitive
  can produce effects much broader than the user's request.
- Preconditions, postconditions, and diff validation can detect stale state,
  truncation, unintended replacement, and unrelated mutation before consequential
  use.
- Existing security, testing, workflow, and ADR governance remains authoritative
  rather than being duplicated.
- Human judgment remains focused where judgment is actually required.

### Negative

- Agentic workflows may require additional mediator components and schemas.
- Narrow tools can require more engineering than exposing a general shell or HTTP
  client.
- Some workflows may become less flexible when arbitrary capability is removed.
- Maintainers must decide what level of verification is proportionate.
- AI-generated work may require additional source inspection or test execution
  before consequential use.
- Context refreshes and independent checks can add latency.

## Compatibility and Migration

Existing repositories are unaffected until they adopt a release containing the AI
safety standard.

Repositories using AI interactively may adopt the epistemic and verification
guidance without building agent infrastructure.

Repositories operating autonomous or semi-autonomous agents should review broad
network, filesystem, shell, credential, and mutation capabilities and introduce
deterministic mediation according to consequence.

The standard does not require immediate redesign of every existing AI workflow.
New or materially changed consequential boundaries should follow the standard as
work occurs, while higher-risk existing workflows should be prioritized.

Existing repository-specific ADRs remain authoritative where they establish a
different deliberate architecture.  Material deviations should remain visible
governance decisions rather than silent exceptions.

## Expected Outcome

AI remains useful for reasoning, drafting, analysis, and recommendation without
being treated as an authoritative source of truth or an unconstrained execution
engine.

Material claims are grounded in evidence.  Uncertainty remains visible.  Stale
state is refreshed when correctness depends on freshness.  Incorrect assumptions
are less likely to propagate unnoticed.

Consequential side effects cross deterministic validation and authorization
boundaries so a plausible model mistake is less likely to become a harmful
operation.

## Related Decisions

- ADR-007 governs general testing evidence and CI trust boundaries.
- ADR-008 governs the IDEA zero-trust security framework.
- ADR-009 governs reusable reference templates and examples.
