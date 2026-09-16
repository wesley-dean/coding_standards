# Welcome

I'm so glad you're thinking about contributing to an open source project.
If you're unsure about anything, just ask -- or submit the issue
or pull request anyway. The worst that can happen is you'll be
politely asked to change something. I love all friendly contributions!

I encourage you to read this project's CONTRIBUTING policy
(you are here), its [LICENSE](LICENSE), and its [README](/README.md).

## Policies

To ensure a welcoming environment for all of our project, I request that
all contributors should adhere to the [code of conduct](CODE_OF_CONDUCT.md).

Changes to the standards, release packaging, or adoption contract should also
follow the governing ADRs beneath `doc/adr/` and the current-decision digest in
[`doc/adr/README.md`](doc/adr/README.md).

## Issue Branches

Work that addresses a tracked issue should use the branch created by Create Issue
Branch when that branch is available.

This repository configures Create Issue Branch to create issue branches
immediately and to use its `full` branch naming scheme:

```text
issue-<issue-number>-<slugified-issue-title>
```

For example, issue 15 titled `Fix nasty bug!` produces a branch similar to:

```text
issue-15-Fix_nasty_bug
```

The branch is created asynchronously after the issue is opened and may not be
visible immediately.  If an expected issue branch is not yet available, retry
before creating a separate branch.

Prefer the generated issue branch over creating a different branch for work that
addresses that issue.

## Build Verification

The canonical release-artifact build is:

```bash
make all
```

A successful build creates:

```text
dist/coding_standards.tar.gz
dist/coding_standards.tar.gz.sha256
```

The `dist/` directory is generated and ignored by Git.  Do not commit its
contents.

To verify that the release archive is deterministic for the same source tree,
run:

```bash
make dist-check
```

## Public domain

This project is in the public domain within the United States, and copyright
and related rights in the work worldwide are waived through the
[CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0 dedication.
By submitting a pull request or issue, you are agreeing to comply with
this waiver of copyright interest.
