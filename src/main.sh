#!/bin/bash

main() {
  BASE_BRANCHES_STR=$1
  GITHUB_TOKEN=$3

  # Convert BASE_BRANCHES string to array
  IFS=',' read -ra BASE_BRANCHES <<<"$BASE_BRANCHES_STR"

  # Get closed PRs (both merged and not merged)
  closed_prs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?state=closed" |
    jq -r '.[] | .head.ref')

  # Get merged PRs
  merged_prs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?state=closed" |
    jq -r '.[] | select(.merged_at != null) | .head.ref')

  # Find closed PRs that are not merged
  not_merged_prs=$(comm -23 <(echo "$closed_prs" | sort) <(echo "$merged_prs" | sort))

  for base_branch in "${BASE_BRANCHES[@]}"; do
    # Loop through branches and delete them
    for branch in $merged_prs; do
      if [ "$branch" != "$base_branch" ]; then
        echo "Deleting merged branch: $branch"
        # Delete merged branch
        curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
          "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
      fi
    done

    # Loop through not merged branches and delete them (if necessary)
    for branch in $not_merged_prs; do
      if [ "$branch" != "$base_branch" ]; then
        echo "Deleting not merged branch: $branch"
        # Delete not merged branch
        curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
          "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
      fi
    done
  done
}
