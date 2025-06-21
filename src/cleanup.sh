#!/bin/env bash

cleanup::delete_merged_branches() {
  local merged_prs=$1
  
  for branch in $merged_prs; do
    # Check if the branch is part of the base branches list
    local is_base_branch=false
    for base_branch in "${BASE_BRANCHES[@]}"; do
      if [[ "$branch" == "$base_branch" ]]; then
        is_base_branch=true
        echo "PROTECTED: Not deleting base branch $branch"
        break
      fi
    done
    
    # Only delete if it is not a base branch
    if [[ "$is_base_branch" == "false" ]]; then
      echo "Deleting merged branch: $branch"
      github::delete_branch "$branch"
    fi
  done
}

cleanup::delete_unmerged_branches() {
  local unmerged_prs=$1
  
  for branch in $unmerged_prs; do
    # Check if the branch is part of the base branches list
    local is_base_branch=false
    for base_branch in "${BASE_BRANCHES[@]}"; do
      if [[ "$branch" == "$base_branch" ]]; then
        is_base_branch=true
        echo "Skipping protected base branch: $branch"
        break
      fi
    done
    
    # Only delete if it is not a base branch
    if [[ "$is_base_branch" == "false" ]]; then
      echo "Deleting not merged branch: $branch"
      github::delete_branch "$branch"
    fi
  done
}

cleanup::delete_inactive_branches() {
  local days_threshold=$1
  
  local inactive_branches
  inactive_branches=$(github::get_inactive_branches "$days_threshold")
  
  for branch in $inactive_branches; do
    # Check if the branch is part of the base branches list
    local is_base_branch=false
    for base_branch in "${BASE_BRANCHES[@]}"; do
      if [[ "$branch" == "$base_branch" ]]; then
        is_base_branch=true
        echo "Skipping protected base branch: $branch"
        break
      fi
    done
    
    # Only delete if it is not a base branch
    if [[ "$is_base_branch" == "false" ]]; then
      echo "Deleting inactive branch: $branch"
      github::delete_branch "$branch"
    fi
  done
}
