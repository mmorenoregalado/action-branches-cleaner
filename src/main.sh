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

    # Eliminar ramas fusionadas
    merged_branches=$(git branch --merged | grep -v "\*" | xargs)
    branches_to_delete=""

    for branch in $merged_branches; do
      branch=$(echo "$branch" | xargs) # Remove leading/trailing whitespaces
      skip_branch=false
      for protected_branch in "${BRANCHES[@]}"; do
        if [[ $branch == *"$protected_branch"* ]]; then
          skip_branch=true
          break
        fi
      done
      if [[ $skip_branch == false ]] && [[ $branch != *"*"* ]]; then
        branches_to_delete+="$branch "
      fi
    done

    if [ -n "$branches_to_delete" ]; then
      echo "Branches to delete: $branches_to_delete"
      for branch in $branches_to_delete; do
        git push origin --delete "$branch"
      done
    else
      echo "No branches to delete."
    fi

    # Eliminar ramas inactivas según el umbral definido
    for branch in $(git for-each-ref --format='%(refname:short)' refs/heads); do
      last_commit_date=$(git show -s --format="%ct" "$branch")
      current_date=$(date +%s)
      days_since_last_commit=$(((current_date - last_commit_date) / 86400))

      if [ $days_since_last_commit -ge "$DAYS_OLD_THRESHOLD" ]; then
        git push origin --delete "$branch"
      fi
    done
  done
}
