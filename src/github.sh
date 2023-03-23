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
