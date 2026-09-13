#!/usr/bin/env bash
# shellcheck shell=bash
## @file scripts/build-bundles.bash
## @brief Builds deterministic release bundles for standards profiles.
## @details
## Produces one archive for each governed language profile plus an all-inclusive
## archive.  Language profiles contain the explicitly configured common standard
## categories, the selected language category, and the corresponding examples.
## The archive root is the distributable standards namespace itself rather than
## an outer `standards/` directory so consumers can materialize an archive
## directly beneath `doc/standards/`.
##
## Bundle generation normalizes ordering, timestamps, ownership metadata, and
## filesystem modes.  Symbolic links are rejected from the maintained standards
## tree, and generated archive paths are validated before checksums are emitted.
## This script intentionally does not publish releases; release orchestration is
## owned by GitHub Actions.

set -euo pipefail

export LC_ALL=C

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPOSITORY_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly STANDARDS_ROOT="${REPOSITORY_ROOT}/standards"
readonly DIST_ROOT="${REPOSITORY_ROOT}/dist"
readonly -a COMMON_CATEGORIES=(general markdown repository adr)
readonly -a LANGUAGE_PROFILES=(awk bash php python)

## @fn die()
## @brief Writes an error message and terminates bundle generation.
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
## @retval 1 Bundle generation cannot continue.
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
## composition or validation failures.
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
## digest="$(sha256_file dist/coding-standards-bash.tar.gz)"
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

## @fn copy_category()
## @brief Copies one tracked standards category into a staging tree when present.
## @details
## Missing categories are intentionally ignored because anticipated common
## categories such as Markdown or ADR standards may exist in the distribution
## contract before their first tracked files are added.  A present category is
## copied as one subtree without interpreting individual standards files.
##
## @param source_root Directory containing category subdirectories.
## @param category Category name to copy.
## @param destination_root Staging directory that receives the category.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Filesystem diagnostics from `mkdir` or `cp` may be written when copying fails.
##
## @returns Nothing is written to STDOUT.
##
## @retval 0 The category was copied or was absent from the source tree.
## @note Non-zero statuses from filesystem commands may be propagated.
##
## @par Examples
## @code
## copy_category standards general /tmp/profile
## @endcode
copy_category() {
  local source_root=$1
  local category=$2
  local destination_root=$3
  local source_path="${source_root}/${category}"

  if [[ ! -d ${source_path} ]]; then
    return 0
  fi

  mkdir -p -- "${destination_root}"
  cp -R -- "${source_path}" "${destination_root}/"
}

## @fn verify_source_tree()
## @brief Verifies source-tree properties required for safe bundle creation.
## @details
## Rejects symbolic links anywhere beneath the distributable standards root.
## Archives are intended to contain ordinary files and directories only; allowing
## links would enlarge the extraction boundary and could make the resulting tree
## depend on paths outside the bundle.
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
  [[ -z ${first_link} ]] || die "symbolic links are not permitted in standards: ${first_link}"
}

## @fn verify_archive()
## @brief Validates path safety and archive-root shape for one generated bundle.
## @details
## Rejects absolute paths, parent-directory traversal, and an accidental outer
## `standards/` directory.  This check is performed on every generated archive
## before its checksum is published so the release artifact preserves the
## materialization contract established by ADR-001.
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
## verify_archive dist/coding-standards-bash.tar.gz
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

## @fn build_profile()
## @brief Builds and verifies one standards profile archive.
## @details
## The `all` profile copies the complete distributable standards tree.  A language
## profile copies each configured common category, the selected language category,
## and examples corresponding to those same categories.  Staged permissions are
## normalized before GNU tar and gzip create deterministic archive metadata.
##
## @param profile Language profile name or `all`.
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
## build_profile bash /tmp/coding-standards-build
## @endcode
build_profile() {
  local profile=$1
  local work_root=$2
  local stage="${work_root}/${profile}"
  local archive="${DIST_ROOT}/coding-standards-${profile}.tar.gz"
  local checksum="${archive}.sha256"
  local category
  local digest

  rm -rf -- "${stage}"
  mkdir -p -- "${stage}"

  if [[ ${profile} == all ]]; then
    cp -R -- "${STANDARDS_ROOT}/." "${stage}/"
  else
    [[ -d ${STANDARDS_ROOT}/${profile} ]] || \
      die "language profile has no standards directory: ${profile}"

    for category in "${COMMON_CATEGORIES[@]}"; do
      copy_category "${STANDARDS_ROOT}" "${category}" "${stage}"
    done
    copy_category "${STANDARDS_ROOT}" "${profile}" "${stage}"

    for category in "${COMMON_CATEGORIES[@]}"; do
      copy_category "${STANDARDS_ROOT}/examples" "${category}" "${stage}/examples"
    done
    copy_category "${STANDARDS_ROOT}/examples" "${profile}" "${stage}/examples"
  fi

  find "${stage}" -type d -exec chmod 0755 {} +
  find "${stage}" -type f -exec chmod 0644 {} +

  tar \
    --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -cf - \
    -C "${stage}" . | gzip -n >"${archive}"

  verify_archive "${archive}"

  digest="$(sha256_file "${archive}")"
  printf '%s  %s\n' "${digest}" "$(basename -- "${archive}")" >"${checksum}"
  printf 'built %s\n' "${archive#"${REPOSITORY_ROOT}/"}"
}

## @fn main()
## @brief Validates the build environment and generates all governed bundles.
## @details
## Performs preflight checks before replacing the local `dist/` directory, stages
## each language profile and the all-inclusive profile in an isolated temporary
## tree, and removes temporary state after successful generation.  The command
## accepts no arguments so release automation and local builds use one unambiguous
## distribution definition.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Writes one informational line for each generated profile archive.
## @par STDERR
## Validation and underlying command diagnostics may be written on failure.
##
## @returns One informational line per generated bundle.
##
## @retval 0 Every governed bundle and checksum was generated successfully.
## @retval 1 A precondition or validation rule failed.
## @note Non-zero statuses from required build utilities may be propagated.
##
## @par Examples
## @code
## ./scripts/build-bundles.bash
## @endcode
main() {
  local work_root
  local profile

  (($# == 0)) || die 'usage: build-bundles.bash'

  require_command basename
  require_command chmod
  require_command cp
  require_command find
  require_command gzip
  require_command grep
  require_command mkdir
  require_command mktemp
  require_command rm
  require_command tar

  tar --version | grep -q 'GNU tar' || die 'GNU tar is required for deterministic bundles'

  verify_source_tree

  rm -rf -- "${DIST_ROOT}"
  mkdir -p -- "${DIST_ROOT}"

  work_root="$(mktemp -d "${TMPDIR:-/tmp}/coding-standards.XXXXXX")"
  trap 'rm -rf -- "${work_root}"' EXIT HUP INT TERM

  for profile in "${LANGUAGE_PROFILES[@]}"; do
    build_profile "${profile}" "${work_root}"
  done
  build_profile all "${work_root}"

  rm -rf -- "${work_root}"
  trap - EXIT HUP INT TERM
}

main "$@"
