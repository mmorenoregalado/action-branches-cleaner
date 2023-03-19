#!/bin/bash

# Función para obtener los PRs cerrados (tanto fusionados como no fusionados)
function get_closed_prs() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/pulls?state=closed" |
    jq -r '.[] | .head.ref'
}

# Función para obtener los PRs fusionados
function get_merged_prs() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/pulls?state=closed" |
    jq -r '.[] | select(.merged_at != null) | .head.ref'
}

# Función para borrar una rama dada
function delete_branch() {
  local branch=$1
  curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API_URL/git/refs/heads/$branch"
}
