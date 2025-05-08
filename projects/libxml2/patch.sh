#!/usr/bin/env bash

# Submodule Patch Helper
# ----------------------
#
# Commands:
#   generate
#     Create patches for all *commits* in the submodule against
#     its current branch's upstream.
#
#   apply [<patch_basename>]
#     Apply either:
#       - the single patch named "<patch_basename>.patch", or
#       - all patches in "patches/libxml2/fuzz" if no basename is given.

SUBMODULE_PATH="libxml2/fuzz"
PATCH_DIR="patches/${SUBMODULE_PATH}"

set -euo pipefail
IFS=$'\n\t'

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

function usage() {
  echo "${BLUE}Usage:${RESET}"
  echo "  $0 generate"
  echo "       Create patches for all commits in the submodule"
  echo "       against its current branch's upstream."
  echo
  echo "  $0 apply"
  echo "       Apply either:"
  echo "         - the single patch named '<patch_basename>.patch', or"
  echo "         - all patches in 'patches/libxml2/fuzz' if no basename is given."
  exit 1
}

function cmd_generate() {
  echo -n "${YELLOW}"
  echo -n "Warning: Make sure all changes are committed "
  echo -n "inside the submodule. Uncommitted changes are not included."
  echo    "${RESET}"

  local root_dir=$(pwd)
  local patch_dir="${root_dir}/${PATCH_DIR}"
  mkdir -p "${patch_dir}"

  pushd "${SUBMODULE_PATH}" > /dev/null

  local branch=$(git rev-parse --abbrev-ref HEAD)
  echo "Using current branch: '${branch}'"

  git format-patch "origin/${branch}" --output-directory "${patch_dir}"

  popd > /dev/null
  echo "${GREEN}Done. Patches available in ${PATCH_DIR}${RESET}"
}

function cmd_apply() {
  local requested=$1

  if [[ ! -d "${PATCH_DIR}" ]]; then
    echo "${RED}Error: patch directory '${PATCH_DIR}' not found.${RESET}" >&2
    exit 2
  elif [[ -z "$(ls -A ${PATCH_DIR})" ]]; then
    echo "${RED}Error: patch directory '${PATCH_DIR}' is empty.${RESET}" >&2
    exit 3
  fi

  local root_dir=$(pwd)
  local patch_dir="${root_dir}/${PATCH_DIR}"
  mkdir -p "${patch_dir}"

  pushd "${SUBMODULE_PATH}" > /dev/null

  if [[ -n "${requested:-}" ]]; then
    local patch="${patch_dir}/${requested}.patch"
    if [[ ! -f "${patch}" ]]; then
      echo "${RED}Error: patch '${patch}' not found.${RESET}" >&2
      popd > /dev/null
      exit 4
    fi

    echo "${BLUE}Applying ${requested}.patch...${RESET}"
    git apply --whitespace=fix "${patch}"
    echo "${GREEN}Patch applied.${RESET}"
  else
    for patch in "${patch_dir}"/*.patch; do
      echo "${BLUE}Applying $(basename "$patch")...${RESET}"
      git apply --whitespace=fix "$patch"
    done
  fi

  popd > /dev/null
  echo "${GREEN}All patches applied.${RESET}"
}

function cmd_reset() {
    pushd "${SUBMODULE_PATH}" > /dev/null

    echo "${BLUE}Resetting all changes...${RESET}"
    git reset --hard 1039cd53
    git clean -fd

    popd > /dev/null
    echo "${GREEN}All changes reset.${RESET}"
}

# Main dispatcher
if [[ $# -lt 1 || $# -gt 2 ]]; then usage; fi

case "$1" in
    generate)
        cmd_generate
    ;;
    apply)
        if [[ $# -gt 2 ]]; then usage; fi
        cmd_apply "${2:-}"
    ;;
    reset)
        cmd_reset
    ;;
    *) usage
    ;;
esac
