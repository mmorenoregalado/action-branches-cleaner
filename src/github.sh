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

  if [[ " ${BASE_BRANCHES[*]} " != *" $branch "* ]]; then
    curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
      "$GITHUB_API_URL/git/refs/heads/$branch"
  fi
}

github::get_branches() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/branches?protected=false" |
    jq -r '.[] | .name'
}

github::get_inactive_branches() {
  local days_inactive=$1
  local all_branches=$(github::get_branches)
  local date_limit=$(date --date="$days_inactive day ago" +%Y-%m-%dT%H:%M:%SZ)

  for branch in $all_branches; do
    local commit_date=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "$GITHUB_API_URL/branches/$branch" |
      jq -r '.commit.commit.committer.date')

    if [[ $(date -d "$commit_date" +%s) -lt $(date -d "$date_limit" +%s) ]]; then
      inactive_branches+=("$branch")
    fi
  done

  echo "${inactive_branches[@]}"

}
