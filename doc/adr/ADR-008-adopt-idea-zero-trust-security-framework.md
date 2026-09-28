# ADR-008: Adopt the IDEA Zero Trust Security Framework

Date: 2026-09-27

## Status

Accepted

## Context

The standards library already contains security-relevant requirements distributed
across clean architecture, development workflow, release governance, testing, and
language-specific practice.  Those standards independently establish useful
boundaries such as treating issue metadata as advisory rather than authoritative,
separating privileged CI publication from untrusted pull-request execution, and
keeping external systems behind explicit architectural interfaces.

The repository does not yet provide one general security model that explains why
those decisions belong together or how maintainers and coding agents should reason
about trust across files, processes, services, identities, generated artifacts,
automation, and external data.

Traditional Zero Trust Architecture is often discussed primarily in terms of
network location, users, devices, services, and resource access.  Those concerns
remain important, but software engineering exposes equally important trust
boundaries through command-line arguments, environment variables, configuration,
files, standard input, subprocess output, repository content, build artifacts,
databases, API responses, and AI-generated content.

Perl's taint mode provides a useful conceptual precedent for treating externally
influenced values as dangerous until a programmer deliberately constrains them.
That model is valuable beyond Perl, but a general engineering standard must go
further: trust is contextual rather than Boolean, validation is use-specific,
authentication and authorization are separate, cryptographic verification
establishes narrow properties rather than universal safety, and downstream
components must re-establish the assumptions required for their own sinks.

The project also needs a disciplined way to discuss uncertainty.  Security
controls provide evidence and reduce risk; they do not establish perfect
certainty.  Stronger controls such as mutual TLS, payload signing, strict
isolation, short-lived credentials, or hardware-backed trust may be desirable but
unavailable or operationally disproportionate in a particular system.  Such
compromises should be visible so maintainers and users can make informed
decisions rather than infer stronger assurance than the implementation provides.

Threat modeling is the natural mechanism for examining trust boundaries.  STRIDE
provides a commonly recognized baseline vocabulary for spoofing, tampering,
repudiation, information disclosure, denial of service, and elevation of
privilege.  It is selected because repeated use of a familiar framework reduces
reviewer onboarding and translation cost across repositories, not because this
decision establishes STRIDE as technically superior to other threat-modeling
methods.

## Decision Drivers

- Establish one coherent general security model across languages and repositories.
- Extend zero-trust reasoning beyond network services to externally influenced
  data and local trust boundaries.
- Treat trust as contextual, explicit, scoped, and non-transitive.
- Separate identity, authentication, authorization, validation, provenance, and
  freshness rather than collapsing them into one notion of trust.
- Preserve Perl-like taint reasoning as a general source-to-sink engineering
  discipline.
- Make cryptographic transport protection a normal baseline while allowing
  stronger end-to-end integrity and provenance where consequence warrants it.
- Prefer mutual cryptographic authentication for critical tooling under common
  administrative control.
- Make threat modeling proportionate and repeatable without turning the standards
  into a compliance checklist.
- Provide a high-level capability-oriented review surface that helps reviewers
  identify where deeper security analysis is warranted.
- Prefer a commonly recognized threat-modeling vocabulary so reviewers can get
  up to speed quickly without implying that the preferred framework is superior
  to suitable alternatives.
- Record assumptions, evidence, limitations, compromises, compensating controls,
  and residual risk.
- Treat security testing as evidence for scoped claims rather than proof of
  universal security.
- Provide explicit guidance for agentic and automated systems without making the
  overall security model AI-specific.
- Keep the model extensible as future security topics become substantial enough
  to warrant additional standards.

## Decision

The standards library SHALL add the general security namespace:

~~~text
standards/general/security/
├── README.md
├── requirements.md
├── review-checklist.md
├── zero-trust.md
├── identity-management.md
├── disclosure.md
├── engineering.md
└── architecture.md
~~~

The namespace SHALL use zero trust as its governing security philosophy and IDEA
as its organizing framework.

IDEA consists of:

- **Identity Management**;
- **Disclosure**;
- **Engineering**; and
- **Architecture**.

IDEA is a taxonomy, not a required sequence.  The domains SHALL be treated as an
iterative model in which discoveries during engineering, threat modeling,
operations, or incident response may revise identity assumptions, architecture,
controls, and disclosure.

### Security Commandments and Reference Consumption

The security landing page SHALL maintain a compact set of stable security
commandments with `SEC-` identifiers.

The commandments SHALL provide concise governing principles suitable for routine
human and automated-agent reference.  Their identifiers SHALL remain stable so
ADRs, threat models, reviews, issues, and implementation discussions can refer to
the same principle over time.  Existing identifiers SHALL NOT be renumbered or
reused for materially different principles.

The detailed zero-trust and IDEA standards remain authoritative for scope,
normative strength, exceptions, tradeoffs, and implementation guidance.

The security corpus SHALL also maintain a semantic requirements index at
`standards/general/security/requirements.md`.

The requirements index SHALL be curated by security intent rather than generated
solely by lexical matching of normative keywords.  It may therefore surface
governing declarative statements in addition to sentences containing `MUST`,
`SHOULD`, `MAY`, and their negative forms.

The index is a discovery and reference surface, not an independent source of
requirements.  When an indexed statement and its detailed source disagree, the
detailed source governs and the index SHALL be corrected.

### Security Review Trigger Checklist

The security corpus SHALL maintain a high-level review trigger checklist at
`standards/general/security/review-checklist.md`.

The checklist SHALL identify capabilities, trust boundaries, and failure
consequences that warrant deeper review without attempting to encode a complete
security audit.

A positive answer SHALL identify review scope rather than be treated as proof of
a vulnerability.  A negative answer SHALL NOT be treated as evidence that the
project is secure.

Checklist prompts SHOULD remain capability-oriented and implementation-neutral so
they can be applied across languages and repositories.  Detailed controls belong
in the relevant IDEA standards and project-specific review.

The checklist SHOULD direct reviewers toward deeper IDEA, STRIDE or governed
alternative, trust-boundary, source-to-sink, and evidence analysis according to
the risk exposed by the answer.

### Zero Trust

The zero-trust standard SHALL reject implicit trust based solely on location,
transport, ownership, familiarity, prior validation, or source reputation.

Trust SHALL be contextual.  A system should establish narrow properties such as
authenticated identity, authorization for a particular operation, validation for
a particular grammar or sink, cryptographic provenance, freshness, or confinement
to a particular resource boundary rather than marking an actor or value
universally trusted.

Trust SHALL NOT be treated as transitive across components or boundaries.

The model SHALL explicitly recognize trust anchors.  Zero trust does not mean an
infinite regress in which nothing can ever be relied upon.  Certificate roots,
signing identities, bootstrap configuration, repository governance, hardware
roots, and other assumptions may serve as trust anchors when they are explicit,
protected, and threat-modeled according to their consequence.

### External Data and Taint

Externally influenced data SHALL be treated as tainted until the properties
required for a specific use have been established.

Relevant inputs include, among others:

- files and file metadata;
- command-line arguments;
- environment variables;
- standard input;
- configuration;
- network input and responses;
- database records;
- subprocess output;
- repository content and metadata;
- generated artifacts; and
- AI-generated output.

Taint reasoning SHALL propagate through derived values.  Parsing, copying,
encoding, hashing, escaping, normalization, serialization, or transformation do
not create a universal trusted state.

Validation SHALL be specific to the intended sink or operation.

Data SHALL NOT acquire authority merely because it is linguistically or
syntactically interpretable as an instruction.

### Identity Management

Identity Management SHALL govern human, service, workload, automation, agent, and
signing identities.

Authentication and authorization SHALL remain separate concepts.

Critical networked tooling SHOULD cryptographically authenticate both endpoints.
For HTTP tooling, HTTPS SHALL be the normal minimum transport.  When both endpoints
are under common project or organizational control, critical tooling SHOULD
normally use mutual TLS or an equivalent mutually authenticated cryptographic
mechanism.

Credential lifecycle SHALL include appropriate generation, storage, issuance,
rotation, expiration, revocation or invalidation, recovery, and destruction.

Identities and credentials SHOULD be purpose-bound and follow least privilege and
least capability.

### Disclosure

Disclosure SHALL make security claims, assumptions, controls, evidence,
limitations, accepted compromises, compensating controls, and residual risk
visible at a level appropriate to the system.

Security documentation SHALL distinguish scoped assurance from claims of perfect
security or certainty.

STRIDE SHALL be the preferred baseline threat-modeling taxonomy unless
repository-specific governance selects another method.

The preference for STRIDE SHALL be understood as a choice for common vocabulary
and reviewer familiarity, not as a claim that STRIDE is more complete, rigorous,
or technically superior to other suitable threat-modeling methods.  Alternative
methods MAY be selected when local governance, domain needs, or system
characteristics justify them.

Threat-modeling depth SHALL be proportionate to consequence, privilege, attack
surface, and data sensitivity.

Disclosure SHALL NOT require publication of sensitive vulnerability information.
Security-sensitive findings remain subject to the repository's private reporting
and incident-handling policy.

Material accepted compromises SHOULD identify a review trigger so temporary or
context-dependent risk does not silently become permanent policy.

### Engineering

Engineering SHALL provide implementation guidance for:

- taint-style source-to-sink reasoning;
- use-specific and point-of-use validation;
- canonicalization where security decisions depend on identity of resources;
- separation of data and control;
- safe subprocess invocation;
- filesystem and environment boundaries;
- HTTPS transport;
- mutual authentication for critical tooling where practical;
- data-level signing or authenticated provenance where integrity must survive
  transport termination;
- encryption when confidentiality must survive the transport boundary;
- freshness and replay resistance;
- supply-chain transformation boundaries;
- least capability;
- fail-closed behavior; and
- safe handling of security diagnostics.

Security controls SHOULD receive executable evidence where practical.

Security testing MAY include static, behavioral, integration, adversarial,
negative, and operational verification.  Testing depth SHALL follow risk rather
than a universal checklist.

Test results SHALL be treated as evidence for the claims actually exercised, not
as proof that the entire system is secure.

### Architecture

Architecture SHALL identify assets, data flows, control flows, credential flows,
trust boundaries, privilege transitions, persistence, and external dependencies
when they materially affect security.

Components SHOULD be compartmentalized so that unrelated capabilities do not need
to coexist.

Network, filesystem, process, credential, and publication authority SHOULD be
restricted according to responsibility.

Privileged operations SHOULD cross narrow interfaces, and more privileged
components SHOULD independently validate requests received from less privileged
components.

Architectures SHALL consider containment, denial of service, recovery, and
re-establishment of trust after compromise.

Build, generation, packaging, minification, conversion, and publication MAY
constitute trust boundaries.  Derived artifacts do not automatically inherit the
trust properties of their source.

## Alternatives Considered

### Add security guidance to existing general standards only

Rejected because security concerns already span architecture, workflow, testing,
release governance, identity, transport, data handling, and automation.  Adding
isolated paragraphs to existing standards would continue to leave the underlying
security model implicit and make it difficult for maintainers or agents to
understand how the requirements relate.

### Create one monolithic zero-trust standard

Rejected because one document would combine philosophy, identity lifecycle,
threat modeling, implementation practice, testing, architecture, and risk
communication into an overly broad standard.

The selected security namespace preserves one coherent model while allowing each
IDEA domain to remain navigable and independently maintainable.

### Name the namespace zero-trust

Rejected because zero trust is the governing philosophy rather than the full
scope of security guidance.  The namespace is therefore
`standards/general/security/`, allowing future security topics to coexist
without being artificially described as zero-trust subtopics.

### Split identity, data, transport, execution, and agents into separate standards

Rejected for the initial model because those categories overlap heavily.  IDEA
organizes the concerns by engineering responsibility rather than by individual
security mechanism.

Future material MAY move into additional standards when it develops enough
independent normative content to be adopted and maintained separately.

### Treat externally authenticated data as trusted

Rejected because authentication of a source does not prove semantic correctness,
authorization, freshness, suitability for a sink, or safety of the resulting
operation.

### Require cryptographic signing of every payload

Rejected as a universal requirement because the operational and key-management
cost can be disproportionate for low-consequence communication.

HTTPS is the normal minimum for HTTP transport.  Independent payload or artifact
signatures are preferred where provenance or integrity must survive transport
termination or cross multiple trust boundaries.

### Require mutual TLS for every HTTP client

Rejected as a universal requirement because many required third-party services do
not support client certificates and the operational cost may be disproportionate
for low-risk interfaces.

Mutual TLS remains the preferred model for critical tooling when both endpoints
are under common administrative control.  Weaker mechanisms require explicit
risk reasoning when the difference is material.

### Mandate a full formal STRIDE artifact for every repository

Rejected because threat-modeling depth should follow risk.

STRIDE remains the preferred baseline taxonomy, but a small utility may need only
a concise boundary review while privileged release or deployment systems may need
substantial documentation.

### Treat passing security tests as proof of security

Rejected because tests exercise finite properties under finite conditions.
Evidence should support scoped claims while limitations and residual uncertainty
remain visible.

## Consequences

### Positive

- The standards library gains one coherent security philosophy.
- Zero-trust reasoning applies consistently to network services, local data,
  repository content, automation, and generated artifacts.
- Humans and coding agents gain a shared vocabulary for explicit trust,
  non-transitivity, taint, trust anchors, sources, sinks, and capability.
- Stable security commandments provide a compact governance surface for routine
  reference, while a semantic requirements index makes detailed governing
  statements discoverable without reducing the corpus to keyword extraction.
- A high-level security review trigger checklist helps reviewers discover attack
  surface, authority, and trust boundaries before deciding where deeper analysis
  is necessary.
- Identity and authorization receive dedicated governance instead of being
  implied by transport security.
- STRIDE provides a repeatable baseline for threat-modeling trust boundaries.
- Security claims can be connected directly to assumptions, controls, evidence,
  limitations, and residual risk.
- Projects can make pragmatic compromises without disguising them as equivalent
  to stronger controls.
- Security testing becomes an evidence mechanism rather than a compliance
  checkbox.
- Agentic workflows receive explicit data/control and capability guidance that
  also benefits non-AI automation.
- The security namespace can grow without requiring the entire corpus to remain
  in one document.

### Negative

- Consuming repositories receive a larger general standards surface.
- Security-sensitive changes may require more documentation and threat modeling.
- Projects must exercise judgment about proportionality rather than follow a
  mechanically complete checklist.
- Mutual TLS, signing, provenance, and credential lifecycle requirements can add
  operational complexity when applicable.
- Maintaining claims, assumptions, evidence, and residual risk creates ongoing
  documentation work.
- The boundaries between IDEA domains require discipline to prevent duplication.

## Compatibility and Migration

Existing repositories are unaffected until they adopt a release containing the
security corpus.

Because the security files are under `standards/general/`, they are
cross-cutting and apply where relevant after adoption unless repository-specific
governance explicitly refines or supersedes them.

Existing accepted repository ADRs remain authoritative where they establish a
different security architecture or deliberate exception.  Adopting this standard
does not silently invalidate an existing local decision.

Repositories do not need to produce exhaustive security documentation immediately
merely because they adopt the release.  New or materially changed security
boundaries should follow the standards as work occurs, while existing high-risk
areas should be prioritized according to project risk.

Future standards MAY refine specific portions of the security corpus.  Such
refinement should preserve the central principles of explicit contextual trust,
least capability, visible uncertainty, and independently enforced boundaries.

The change is a new standards capability.  Under the repository's Conventional
Commit and Semantic Versioning governance, the integration commit is intended to
use a `feat:` classification and therefore request a minor-version increment.

## Expected Outcome

A maintainer or coding agent can begin with
`standards/general/security/README.md`, understand the zero-trust philosophy,
and navigate the IDEA domains according to the current task.

Security-sensitive work identifies explicit trust boundaries and identities,
threat-models consequential flows, implements proportionate controls, creates
evidence where practical, and records assumptions, limitations, compromises, and
residual risk.

The resulting security posture is not represented as perfect certainty.  It is a
reviewable body of claims, controls, evidence, and known risk that allows users
and maintainers to make informed decisions.

## Related Decisions

- ADR-003 governs standards distribution and explicit consumer adoption.
- ADR-005 governs ADR acceptance semantics.
- ADR-006 governs the current-decision landing page.
- ADR-007 governs general testing evidence and CI trust-boundary guidance.
