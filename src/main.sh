#!/bin/env bash

# Importar funciones de github.sh
source "$BRANCHES_CLEANER_HOME"/src/github.sh
# Importar funciones de cleanup.sh
source "$BRANCHES_CLEANER_HOME"/src/cleanup.sh

main() {
  BASE_BRANCHES_STR=$1
  GITHUB_TOKEN=$3

  GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPOSITORY"

  export GITHUB_TOKEN
  export GITHUB_API_URL

  # Convert BASE_BRANCHES string to array
  IFS=',' read -ra BASE_BRANCHES <<<"$BASE_BRANCHES_STR"

  # Get closed PRs (both merged and not merged)
  closed_prs=$(github::get_closed_prs)

  # Get merged PRs
  merged_prs=$(github::get_merged_prs)

  # Find closed PRs that are not merged
  not_merged_prs=$(comm -23 <(echo "$closed_prs" | sort) <(echo "$merged_prs" | sort))

  for base_branch in "${BASE_BRANCHES[@]}"; do

    # Delete merged branches
    cleanup::delete_merged_branches "$merged_prs" "$base_branch"

    # Delete unmerged branches
    cleanup::delete_unmerged_branches "$not_merged_prs" "$base_branch"
  done
}
