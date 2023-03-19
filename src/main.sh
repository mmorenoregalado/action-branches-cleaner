#!/bin/bash

main() {
  BASE_BRANCHES=$1
  GITHUB_TOKEN=$3

  # Get merged PRs
  merged_prs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?state=closed&base=$BASE_BRANCHES" |
    jq -r '.[] | select(.merged_at != null) | .head.ref')

  # Loop through branches and delete them
  for branch in $merged_prs; do
    if [ "$branch" != "$BASE_BRANCHES" ]; then
      echo "Deleting merged branch: $branch"
      # Delete merged branch
      curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
    fi
  done

}
