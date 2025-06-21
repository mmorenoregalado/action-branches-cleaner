#!/bin/env bash

##
# Determine the project root path. In the normal GitHub Action runtime this is
# provided via the `BRANCHES_CLEANER_HOME` environment variable, but when the
# scripts are sourced directly (e.g. during unit tests) this variable might not
# be defined.  In that case fall back to resolving the path relative to this
# file.
##

if [ -z "${BRANCHES_CLEANER_HOME:-}" ]; then
  BRANCHES_CLEANER_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
fi

source "$BRANCHES_CLEANER_HOME"/src/github.sh
source "$BRANCHES_CLEANER_HOME"/src/cleanup.sh

main() {
  BASE_BRANCHES_STR=$1
  DAYS_OLD_THRESHOLD=$2
  GITHUB_TOKEN=$3

  GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPOSITORY"

  export GITHUB_TOKEN
  export GITHUB_API_URL

  IFS=',' read -ra BASE_BRANCHES <<<"$BASE_BRANCHES_STR"

  export BASE_BRANCHES

  closed_prs=$(github::get_closed_prs)

  merged_prs=$(github::get_merged_prs)

  not_merged_prs=$(comm -23 <(echo "$closed_prs" | sort) <(echo "$merged_prs" | sort))

  cleanup::delete_merged_branches "$merged_prs"

  cleanup::delete_unmerged_branches "$not_merged_prs"

  cleanup::delete_inactive_branches "$DAYS_OLD_THRESHOLD"
}
