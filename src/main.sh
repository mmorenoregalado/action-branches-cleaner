#!/bin/bash

main() {
  BASE_BRANCHES=$1
  GITHUB_TOKEN=$3

  # Get closed PRs (both merged and not merged)
  closed_prs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?state=closed&base=$BASE_BRANCHES" |
    jq -r '.[] | .head.ref')

  # Get merged PRs
  merged_prs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?state=closed&base=$BASE_BRANCHES" |
    jq -r '.[] | select(.merged_at != null) | .head.ref')

  # Find closed PRs that are not merged
  not_merged_prs=$(comm -23 <(echo "$closed_prs" | sort) <(echo "$merged_prs" | sort))

  # Loop through branches and delete them
  for branch in $merged_prs; do
    if [ "$branch" != "$BASE_BRANCHES" ]; then
      echo "Deleting merged branch: $branch"
      # Delete merged branch
      curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
    fi
  done

  # Loop through not merged branches and delete them (if necessary)
  for branch in $not_merged_prs; do
    if [ "$branch" != "$BASE_BRANCHES" ]; then
      echo "Deleting not merged branch: $branch"
      # Delete not merged branch
      curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
    fi
  done

}
