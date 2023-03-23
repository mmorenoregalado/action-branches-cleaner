#!/bin/env bash

github::get_closed_prs() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/pulls?state=closed" |
    jq -r '.[] | .head.ref'
}

github::get_merged_prs() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/pulls?state=closed" |
    jq -r '.[] | select(.merged_at != null) | .head.ref'
}

github::delete_branch() {
  local branch=$1
  curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/git/refs/heads/$branch"
}

github::get_inactive_branches() {
  local days_inactive=$1
  local all_branches=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "$GITHUB_API_URL/repos/$repo_full_name/branches")
  local cutoff=$(date --date="$days_inactive day ago" +%Y-%m-%dT%H:%M:%SZ)
  echo "$all_branches" | jq -r --arg cutoff "$cutoff" '.[] | select(.commit.committer.date < $cutoff) | .name'
}
