# ADR-018: Migrate Repository Routine Dependency Updates to Central Renovate

Date: 2026-11-26

## Status

Accepted

## Decision

This repository SHALL explicitly enroll in the externally managed, Jenkins-hosted Renovate service through a minimal root `renovate.json`. There is currently no active repository Dependabot version-update configuration to disable. This decision governs the maintainer repository itself, not the standards published to other repositories.

Routine dependency updates shall be owned by the centralized Renovate runner. Dependabot advisory-driven security updates and vulnerability alerts remain separate. Existing `dependabot[bot]`-scoped security PR workflows are not extended to Renovate. Required checks, code-owner approval, and repository protection remain authoritative; neither Renovate nor this migration may bypass them.

ADR-017 defines a published shared Dependabot baseline for consumers. It is **not superseded** by repository-local Renovate enrollment. Updating that public standards contract requires a separately justified, versioned standards change.

## Context and Conditions

The maintainer now operates one centralized Renovate job covering `wesley-dean/*`; per-repository routine Dependabot schedules duplicate version proposals and review effort. Explicit enrollment is necessary, with no repository-local runner credentials, GitHub Actions job, or Jenkins change.

Relevant repository-specific trust boundaries include Published versioned coding-standards archives and independently adopted consumer governance. Existing public interfaces, artifact formats, release verification, dependency checksums, and signed-commit or approval requirements must not change.

## Assumptions

- Jenkins already discovers `wesley-dean/*` and uses the root enrollment to decide which repositories to process.
- Machine-account write access will be granted by the maintainer when reviewing migration PRs.
- Renovate's native auto-merge is still gated by required checks and human approval.
- GitHub vulnerability alerting and Dependabot security-update settings are managed independently.
- Successful configuration merge does not establish that a later Renovate job succeeded.

## Alternatives Considered

1. Keep scheduled Dependabot maintenance alongside Renovate. Rejected because duplicate update PRs and schedules defeat the centralization goal.
2. Delete Dependabot configuration wholesale. Rejected where it exists because remaining GitHub security-update behavior and provenance should be preserved.
3. Add a Renovate workflow or secrets to each repository. Rejected because operational policy, credentials, and signing already live centrally.
4. Broaden the Dependabot-specific auto-merge workflow to include Renovate. Rejected because bot identity and approval boundaries must remain separate.
5. Convert verified immutable action SHA pins to floating tags. Rejected because doing so weakens supply-chain immutability unnecessarily.
6. Stop migration when one pinned SHA has no verifiable release. Rejected for this portfolio: use a temporarily unpinned but syntactically valid `@version` reference for that action, document the risk, and let Renovate resolve the version in a follow-up PR.

## Migration and Compatibility

The reviewed migration PR adds `renovate.json` and, when applicable, disables scheduled Dependabot version PRs. It may normalize comment-only `# pin@` annotations after checking exact upstream tag-to-commit mappings. Where an existing SHA cannot be matched to a release, remove the SHA and obsolete pin comment and replace it with a syntactically valid moving version ref (for example, `@v5`), explicitly recording this temporary trust downgrade for subsequent Renovate remediation. Never emit `uses: owner/repo` without an `@ref`.

Existing ordinary Dependabot PRs are retired immediately after the migration PR is created, with an explanatory link. Security advisories and ambiguous PRs stay open. There is no promise of immediate Renovate execution, replacement PR generation, or successful pin restoration. Test, security, signing, release, and permission controls remain unchanged.

## Threats and Consequences

The central Renovate account gains PR-writing authority, and a temporarily moving upstream action ref can change without a review of a fixed SHA. This creates a narrower period of elevated supply-chain risk until a reviewed Renovate PR re-establishes a verified pin. Preserve human review, required CI, least-privilege tokens, independent Dependabot security maintenance, and targeted validation of high-authority publication actions. Do not auto-approve a PR solely because it comes from Renovate.

## Related Decisions

ADR-003, ADR-009, ADR-012, ADR-015, ADR-017 govern unchanged repository architecture and supply-chain trust. ADR-017 continues to govern the distributed Dependabot reference policy for consumers.
