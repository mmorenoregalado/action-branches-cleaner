#!/bin/bash

# Importar funciones de github.sh
source "$BRANCHES_CLEANER_HOME"/src/github.sh

main() {
  BASE_BRANCHES_STR=$1
  GITHUB_TOKEN=$3

  GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPOSITORY"

  export GITHUB_TOKEN
  export GITHUB_API_URL

  # Convert BASE_BRANCHES string to array
  IFS=',' read -ra BASE_BRANCHES <<<"$BASE_BRANCHES_STR"

  # Get closed PRs (both merged and not merged)
  closed_prs=$(get_closed_prs)

  # Get merged PRs
  merged_prs=$(get_merged_prs)

  # Find closed PRs that are not merged
  not_merged_prs=$(comm -23 <(echo "$closed_prs" | sort) <(echo "$merged_prs" | sort))

  for base_branch in "${BASE_BRANCHES[@]}"; do
    # Loop through branches and delete them
    for branch in $merged_prs; do
      if [ "$branch" != "$base_branch" ]; then
        echo "Deleting merged branch: $branch"
        # Delete merged branch
        delete_branch "$branch"
      fi
    done

    # Loop through not merged branches and delete them (if necessary)
    for branch in $not_merged_prs; do
      if [ "$branch" != "$base_branch" ]; then
        echo "Deleting not merged branch: $branch"
        # Delete not merged branch
        delete_branch "$branch"
      fi
    done
  done
}
