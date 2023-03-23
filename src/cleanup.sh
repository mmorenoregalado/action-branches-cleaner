#!/bin/env bash

cleanup::delete_merged_branches() {
  local merged_prs=$1
  local base_branch=$2
  for branch in $merged_prs; do
    if [ "$branch" != "$base_branch" ]; then
      echo "Deleting merged branch: $branch"
      github::delete_branch "$branch"
    fi
  done
}

cleanup::delete_unmerged_branches() {
  local not_merged_prs=$1
  local base_branch=$2
  for branch in $not_merged_prs; do
    if [ "$branch" != "$base_branch" ]; then
      echo "Deleting not merged branch: $branch"
      github::delete_branch "$branch"
    fi
  done
}

cleanup::delete_inactive_branches() {
  local days_inactive=$1
  local inactive_branches=$(github::get_inactive_branches "$days_inactive")

  for branch in $inactive_branches; do
    echo "Deleting inactive branch: $branch"
    # Delete inactive branch
    github::delete_branch "$branch"
  done
}
