# ADR-011: Adopt Conventional Branch Naming With an Agent Provenance Namespace

Date: 2026-10-04

## Status

Accepted

## Context

The standards library governs development workflow, Conventional Commit release
classification, agent behavior, zero-trust engineering, and reviewed pull-request
integration, but it does not currently define a reusable branch-naming convention.

This repository separately configures Create Issue Branch to create branches
automatically when issues are opened or assigned.  That workflow uses names such
as:

```text
issue-15-Fix_nasty_bug
```

The generated name couples branch creation to issue creation, does not communicate
the semantic purpose of the work in a standard form, and does not identify whether
an automated coding agent owns the branch.

Agent provenance has become operationally significant.  Deterministic tooling may
need to discover agent-owned branches, apply additional review or signing
workflows, or distinguish agent-created work from human-created work.  A branch
name can provide a useful routing signal for those workflows, although the name
alone is not proof of authorship or authorization.

Conventional Branch 1.1.0 defines a portable branch convention using:

```text
<type>/<description>
```

with lowercase, hyphen-separated descriptions and purpose prefixes including
`feature`, `feat`, `bugfix`, `fix`, `hotfix`, `release`, and `chore`.
It also defines AI source prefixes such as `ai/`, `claude/`, `codex/`, and
`copilot/`.

The project requires one vendor-neutral provenance namespace, `agent/`, while
also retaining the semantic purpose classification.  The resulting nested form is
therefore an intentional project extension of Conventional Branch rather than a
claim of strict conformance with the upstream grammar.

References:

- <https://conventionalbranch.org/>
- <https://conventionalbranch.org/v1.1.0/>

## Decision Drivers

- Use an established branch-naming vocabulary where practical.
- Keep branch purpose human-readable and machine-readable.
- Make agent-owned work discoverable through one stable vendor-neutral prefix.
- Avoid coupling branch creation to issue creation.
- Keep branch names independent of whether a GitHub issue exists.
- Preserve compatibility with deterministic agent-branch signing and review tools.
- Keep provenance signaling separate from proof of commit identity.
- Prefer lowercase, URL-friendly, shell-friendly, hyphen-separated descriptions.
- Avoid vendor-specific agent prefixes in repository governance.
- Keep branch naming advisory to release classification; pull-request and final
  commit titles remain the governed release signals.

## Decision

Repositories adopting the Development Workflow and Backlog Governance standard
SHOULD use Conventional Branch naming for non-agent development branches:

```text
<type>/<description>
```

The supported purpose types are:

```text
feature
feat
bugfix
fix
hotfix
release
chore
```

Descriptions SHALL follow Conventional Branch description rules: lowercase
alphanumeric segments, optional dots within segments, and hyphens between
segments.  Spaces, underscores, uppercase letters, leading or trailing hyphens,
and consecutive hyphens are not permitted.

Examples include:

```text
feat/add-manifest-validation
fix/reject-empty-owner
chore/update-development-tooling
release/v2.1.0
```

### Agent-Owned Branches

A branch created and owned by an automated coding agent SHALL begin with the
vendor-neutral `agent/` namespace and SHALL retain the Conventional Branch
purpose classification as the next path component:

```text
agent/<type>/<description>
```

Examples include:

```text
agent/feat/add-manifest-validation
agent/fix/reject-empty-owner
agent/chore/update-development-tooling
agent/release/prepare-v2.1.0
```

The `agent/` namespace is a project extension to Conventional Branch 1.1.0.
The nested form intentionally preserves both provenance and purpose even though
the upstream grammar defines one prefix component.

Vendor-specific prefixes such as `codex/`, `claude/`, or `copilot/` SHALL
NOT be required by this governance.  Repository tooling SHOULD key generic
agent-owned workflows from `agent/*`.

### Provenance Is a Routing Signal

An `agent/` branch name SHALL NOT be treated as proof that every commit on the
branch was authored by an authorized agent.

Security-sensitive automation MUST independently verify the properties it relies
upon, such as commit author and committer identity, signature validity, branch
history, repository ownership, authorization, or current remote state.

A human commit, merge commit, or otherwise unexpected history on an `agent/`
branch may form a trust boundary for downstream tooling.

### Relationship to Issues

Issue numbers SHALL NOT be required in branch names.

A branch MAY address one issue, several issues, or work authorized through another
repository-recognized mechanism.  Issue linkage belongs in pull requests, commit
messages, or other reviewable metadata where appropriate.

Branch creation SHOULD occur when work begins rather than automatically when an
issue is opened.

### Relationship to Conventional Commits

Branch classification is descriptive development metadata.  It SHALL NOT replace
the repository's reviewed Conventional Commit or release-classification signal.

The pull-request title and final target-branch commit remain authoritative for
semantic release significance under Conventional Commit and Release Versioning
Governance.

A `feat/` or `agent/feat/` branch therefore does not itself authorize a minor
release, and a branch name SHALL NOT override the reviewed semantic significance
of the completed change.

### Existing Branches

Existing branches are not required to be renamed retroactively.

New branches created after adoption SHOULD follow this decision.  Repositories MAY
delete stale merged branches independently under their normal maintenance policy.

## Alternatives Considered

### Keep Create Issue Branch and `issue-*` Names

Rejected because branch existence would continue to mean that an issue exists
rather than that work has begun.  The generated names also omit a standard purpose
classification and do not provide a stable agent provenance namespace.

### Include Issue Numbers in the Standard Name

A form such as:

```text
agent/feat/12,34-add-resigning-scripts
```

was considered and rejected.

Issue numbers can be useful for traceability, but requiring them would create a
larger local naming grammar and move farther from an established branch
convention.  Issue linkage remains available through pull requests and commits
without burdening the branch grammar.

### Use Conventional Branch AI Prefixes Directly

Using `ai/<description>`, `codex/<description>`, or another upstream AI source
prefix was considered.

The project instead needs one stable provenance namespace that is independent of
model vendor or agent implementation, and it needs to preserve the purpose type as
a separately parseable component.  `agent/<type>/<description>` satisfies those
requirements at the cost of becoming an explicit project extension.

### Use `agent/<description>` Only

Rejected because provenance would be visible but the branch purpose would no
longer be available as a separate machine-readable component.

## Consequences

Positive consequences include:

- agent-owned branches are discoverable through `agent/*`;
- branch purpose remains explicit through a known Conventional Branch vocabulary;
- deterministic tooling can route agent branches without depending on model
  vendor names;
- branch creation becomes evidence that work has begun rather than a side effect
  of issue creation;
- descriptions become consistently lowercase and hyphen-separated; and
- issue tracking remains decoupled from branch naming.

Tradeoffs include:

- `agent/<type>/<description>` is a local extension rather than strict
  Conventional Branch 1.1.0 syntax;
- generic Conventional Branch validators may require local configuration to
  accept the nested namespace;
- existing `issue-*` and older `agent/*` branches may remain until merged or
  deleted; and
- tooling that assumes a one-component branch prefix must understand the
  additional `agent/` namespace.

## Expected Outcomes

New human-created development branches will use Conventional Branch purpose
prefixes, while new agent-owned branches will use the same purpose vocabulary
beneath `agent/`.

Repository automation can use `agent/*` for broad provenance routing and inspect
the second component when purpose-specific behavior is needed.

Create Issue Branch automation and its `issue-*` naming guidance will be removed
from this repository.

## Relationships

This decision extends Development Workflow and Backlog Governance with branch
naming and agent provenance requirements.

It complements Conventional Commit and Release Versioning Governance but does not
change its authoritative release-classification signals.

It also complements ADR-008 and ADR-010: branch provenance may inform zero-trust
routing and containment, but deterministic verification remains required for
security-sensitive conclusions.
