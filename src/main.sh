#!/bin/bash

main() {
  BASE_BRANCHES=$1
  DAYS_OLD_THRESHOLD=$2
  GITHUB_TOKEN=$3

  git config --global user.email "action@github.com"
  git config --global user.name "GitHub Action"

  REPO_URL=$(git config --get remote.origin.url)
  AUTHENTICATED_REPO_URL="https://${GITHUB_TOKEN}@${REPO_URL#*//}"
  git remote set-url origin "$AUTHENTICATED_REPO_URL"

  git fetch --all --prune

  # Leer ramas base y convertirlas en array
  IFS=',' read -ra BRANCHES <<<"$BASE_BRANCHES"

  for base_branch in "${BRANCHES[@]}"; do
    git checkout "$base_branch"

    merged_branches=$(git branch -r --merged "origin/$base_branch" | grep -v "origin/$base_branch" | sed 's/origin\///' | xargs || true)

    if [ -n "$merged_branches" ]; then
      echo "Merged branches found: $merged_branches"
      for branch in $merged_branches; do
        echo "Deleting branch: $branch"
        git push origin --delete "$branch"
      done
    else
      echo "No merged branches found."
    fi

    for branch in $(git for-each-ref --format='%(refname:short)' refs/heads); do
      last_commit_date=$(git show -s --format="%ct" "$branch")
      current_date=$(date +%s)
      days_since_last_commit=$(((current_date - last_commit_date) / 86400))

      if [ $days_since_last_commit -ge "$DAYS_OLD_THRESHOLD" ]; then
        echo "Deleting inactive branch: $branch"
        git push origin --delete "$branch"
      fi
    done
  done
}
