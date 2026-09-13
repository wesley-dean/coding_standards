#!/usr/bin/env bash
# shellcheck shell=bash
## @file scripts/build-bundles.bash
## @brief Builds the deterministic coding-standards release archive.
## @details
## Produces one archive containing the complete contents of `standards/`.  The
## archive root is the distributable standards namespace itself rather than an
## outer `standards/` directory so consumers can materialize the archive directly
## beneath `doc/standards/`.
##
## Archive generation normalizes ordering, timestamps, ownership metadata, and
## filesystem modes.  Symbolic links are rejected from the maintained standards
## tree, and generated archive paths are validated before the checksum is emitted.
## This script intentionally does not publish releases; release orchestration is
## owned by GitHub Actions.

set -euo pipefail

export LC_ALL=C

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPOSITORY_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly STANDARDS_ROOT="${REPOSITORY_ROOT}/standards"
readonly DIST_ROOT="${REPOSITORY_ROOT}/dist"
readonly ARCHIVE="${DIST_ROOT}/coding-standards.tar.gz"
readonly CHECKSUM="${ARCHIVE}.sha256"

## @fn die()
## @brief Writes an error message and terminates archive generation.
## @details
## Centralizes fatal diagnostics so failed preconditions and validation errors use
## one predictable format.  The function does not attempt recovery because a
## partial distribution build must never be treated as successful.
##
## @param message Human-readable failure description.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Writes one error line containing the supplied message.
##
## @returns Nothing is written to STDOUT.
##
## @retval 1 Archive generation cannot continue.
##
## @par Examples
## @code
## die 'GNU tar is required'
## @endcode
die() {
  local message=$1

  printf 'error: %s\n' "${message}" >&2
  exit 1
}

## @fn require_command()
## @brief Verifies that a required command is available.
## @details
## Fails before publication work begins when a required build capability cannot be
## located through PATH.  This keeps missing-tool failures separate from archive
## construction or validation failures.
##
## @param command_name Command that must resolve through PATH.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## A fatal diagnostic is written by `die()` when the command is unavailable.
##
## @returns Nothing is written to STDOUT.
##
## @retval 0 The required command is available.
## @note If the command is unavailable, `die()` terminates the script with status 1.
##
## @par Examples
## @code
## require_command tar
## @endcode
require_command() {
  local command_name=$1

  command -v "${command_name}" >/dev/null 2>&1 || \
    die "required command not found: ${command_name}"
}

## @fn sha256_file()
## @brief Calculates the SHA-256 digest of one file.
## @details
## Prefers `sha256sum` and falls back to `shasum -a 256`.  The function emits
## only the lowercase hexadecimal digest so callers can construct deterministic
## checksum files independently of tool-specific filename formatting.
##
## @param path File whose exact bytes are hashed.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Writes one lowercase hexadecimal SHA-256 digest followed by a newline.
## @par STDERR
## Underlying hashing-tool diagnostics may be written when hashing fails.  A fatal
## diagnostic is written by `die()` when no supported SHA-256 command exists.
##
## @returns A single SHA-256 digest line.
##
## @retval 0 The digest was calculated successfully.
## @note Non-zero statuses from the selected hashing command may be propagated.
##
## @par Examples
## @code
## digest="$(sha256_file dist/coding-standards.tar.gz)"
## @endcode
sha256_file() {
  local path=$1
  local output

  if command -v sha256sum >/dev/null 2>&1; then
    output="$(sha256sum -- "${path}")"
  elif command -v shasum >/dev/null 2>&1; then
    output="$(shasum -a 256 -- "${path}")"
  else
    die 'sha256sum or shasum -a 256 is required'
  fi

  printf '%s\n' "${output%% *}"
}

## @fn cleanup_tree()
## @brief Removes a build-owned temporary directory without broad path deletion.
## @details
## Deletes only descendants of the exact temporary directory supplied by the
## caller and then removes that directory itself.  The helper refuses empty or
## root paths so cleanup cannot accidentally expand beyond build-owned state.
##
## @param path Temporary directory created by this script.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Filesystem diagnostics may be written if cleanup fails.
##
## @returns Nothing is written to STDOUT.
##
## @retval 0 The directory was absent or was removed successfully.
## @retval 1 The supplied path was empty or `/`.
## @note Non-zero statuses from `find` or `rmdir` may be propagated.
##
## @par Examples
## @code
## cleanup_tree "${work_root}"
## @endcode
cleanup_tree() {
  local path=$1

  [[ -n ${path} && ${path} != / ]] || return 1
  [[ -d ${path} ]] || return 0

  find "${path}" -depth -mindepth 1 -delete
  rmdir -- "${path}"
}

## @fn verify_source_tree()
## @brief Verifies source-tree properties required for safe archive creation.
## @details
## Rejects symbolic links anywhere beneath the distributable standards root.
## Archives are intended to contain ordinary files and directories only; allowing
## links would enlarge the extraction boundary and could make the resulting tree
## depend on paths outside the archive.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## A fatal diagnostic is written when the standards root is missing or contains a
## symbolic link.
##
## @returns Nothing is written to STDOUT.
##
## @retval 0 The maintained standards tree satisfies source safety requirements.
## @note On validation failure, `die()` terminates the script with status 1.
##
## @par Examples
## @code
## verify_source_tree
## @endcode
verify_source_tree() {
  local first_link

  [[ -d ${STANDARDS_ROOT} ]] || die "standards root not found: ${STANDARDS_ROOT}"

  first_link="$(find "${STANDARDS_ROOT}" -type l -print -quit)"
  [[ -z ${first_link} ]] || \
    die "symbolic links are not permitted in standards: ${first_link}"
}

## @fn verify_archive()
## @brief Validates path safety and archive-root shape for the generated archive.
## @details
## Rejects absolute paths, parent-directory traversal, and an accidental outer
## `standards/` directory.  This check runs before the checksum is published so
## the release artifact preserves the materialization contract established by
## ADR-001.
##
## @param archive Generated `.tar.gz` archive to inspect.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## `tar` diagnostics may be written when the archive cannot be read.  A fatal
## diagnostic is written when an unsafe or incorrectly rooted member is found.
##
## @returns Nothing is written to STDOUT.
##
## @retval 0 Every archive member satisfies the path contract.
## @note Non-zero statuses from `tar` may be propagated.
##
## @par Examples
## @code
## verify_archive dist/coding-standards.tar.gz
## @endcode
verify_archive() {
  local archive=$1
  local entry
  local normalized

  while IFS= read -r entry; do
    normalized=${entry#./}

    case ${normalized} in
      ''|.)
        continue
        ;;
      /*|..|../*|*/../*|*/..)
        die "unsafe archive member in ${archive}: ${entry}"
        ;;
      standards|standards/*)
        die "archive contains forbidden outer standards directory: ${entry}"
        ;;
    esac
  done < <(tar -tzf "${archive}")
}

## @fn build_archive()
## @brief Builds and verifies the complete standards release archive.
## @details
## Copies the complete distributable standards tree into an isolated staging
## directory, normalizes permissions, creates deterministic tar and gzip metadata,
## verifies the generated archive, and writes its SHA-256 checksum file.
##
## @param work_root Temporary directory used for isolated staging.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Writes one line identifying the generated archive.
## @par STDERR
## Filesystem, tar, gzip, or validation diagnostics may be written on failure.
##
## @returns One informational line naming the generated archive.
##
## @retval 0 The archive and its checksum were generated successfully.
## @note Non-zero statuses from build utilities may be propagated.
##
## @par Examples
## @code
## build_archive /tmp/coding-standards-build
## @endcode
build_archive() {
  local work_root=$1
  local stage="${work_root}/standards"
  local digest

  mkdir -p -- "${stage}"
  cp -R -- "${STANDARDS_ROOT}/." "${stage}/"

  find "${stage}" -type d -exec chmod 0755 {} +
  find "${stage}" -type f -exec chmod 0644 {} +

  tar \
    --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -cf - \
    -C "${stage}" . | gzip -n >"${ARCHIVE}"

  verify_archive "${ARCHIVE}"

  digest="$(sha256_file "${ARCHIVE}")"
  printf '%s  %s\n' "${digest}" "$(basename -- "${ARCHIVE}")" >"${CHECKSUM}"
  printf 'built %s\n' "${ARCHIVE#"${REPOSITORY_ROOT}/"}"
}

## @fn main()
## @brief Validates the build environment and generates the release archive.
## @details
## Performs preflight checks, stages the complete standards tree in an isolated
## temporary directory, generates one deterministic archive and checksum, and
## removes temporary state after success.  The command accepts no arguments so
## release automation and local builds use one unambiguous distribution definition.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Writes one informational line naming the generated archive.
## @par STDERR
## Validation and underlying command diagnostics may be written on failure.
##
## @returns One informational line naming the generated archive.
##
## @retval 0 The archive and checksum were generated successfully.
## @retval 1 A precondition or validation rule failed.
## @note Non-zero statuses from required build utilities may be propagated.
##
## @par Examples
## @code
## ./scripts/build-bundles.bash
## @endcode
main() {
  local work_root

  (($# == 0)) || die 'usage: build-bundles.bash'

  require_command basename
  require_command chmod
  require_command cp
  require_command find
  require_command gzip
  require_command grep
  require_command mkdir
  require_command mktemp
  require_command rmdir
  require_command tar

  tar --version | grep -q 'GNU tar' || \
    die 'GNU tar is required for deterministic archives'

  verify_source_tree

  mkdir -p -- "${DIST_ROOT}"
  rm -f -- "${ARCHIVE}" "${CHECKSUM}"

  work_root="$(mktemp -d "${TMPDIR:-/tmp}/coding-standards.XXXXXX")"
  trap 'cleanup_tree "${work_root}"' EXIT HUP INT TERM

  build_archive "${work_root}"

  cleanup_tree "${work_root}"
  trap - EXIT HUP INT TERM
}

main "$@"
