#!/bin/bash

main() {
  BASE_BRANCHES=$1
  GITHUB_TOKEN=$3


  # Get merged branches
  branches=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/branches" | \
    jq -r '.[].name')

  # Loop through branches and check if they are merged into the base branch
  for branch in $branches; do
    if [ "$branch" != "$BASE_BRANCHES" ]; then
      is_merged=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/compare/$BASE_BRANCHES...$branch" | \
        jq -r '.merge_commit_sha')

      if [ "$is_merged" != "null" ]; then
        echo "Deleting merged branch: $branch"
        # Delete merged branch
        curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
          "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$branch"
      fi
    fi
  done

}
