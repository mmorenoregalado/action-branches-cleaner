#!/bin/env bash

cleanup::delete_merged_branches() {
  local merged_prs=$1
  for branch in $merged_prs; do
    echo "Deleting merged branch: $branch"
    github::delete_branch "$branch"
  done
}

cleanup::delete_unmerged_branches() {
  local not_merged_prs=$1
  for branch in $not_merged_prs; do
    echo "Deleting not merged branch: $branch"
    github::delete_branch "$branch"
  done
}
