#!/usr/bin/env bash
set -e

# Determine repository root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Mock functions to avoid real API calls
github::get_branches() {
  echo "feature/old"
  echo "feature/new"
  echo "main"
}

curl() {
  if [[ $* == *"branches/feature/old"* ]]; then
    echo '{"commit": {"commit": {"committer": {"date": "2020-01-01T00:00:00Z"}}}}'
  elif [[ $* == *"branches/feature/new"* ]]; then
    echo '{"commit": {"commit": {"committer": {"date": "2023-01-10T00:00:00Z"}}}}'
  elif [[ $* == *"branches/main"* ]]; then
    echo '{"commit": {"commit": {"committer": {"date": "2023-01-11T00:00:00Z"}}}}'
  else
    echo "Endpoint no esperado: $*" >&2
    echo '{}'
  fi
}

date() {
  if [[ $* == *"--date="* ]]; then
    if [[ $* == *"--date=7 day ago"* ]]; then
      echo "2023-01-05T00:00:00Z"
    else
      local days
      days=$(echo "$*" | sed -n 's/.*--date=\([0-9]\+\).*/\1/p')
      echo "2023-01-$((12 - days))T00:00:00Z"
    fi
  elif [[ $* == *"-d "* ]]; then
    if [[ $* == *"-d 2020-01-01T00:00:00Z"* ]]; then
      echo "1577836800"
    elif [[ $* == *"-d 2023-01-05T00:00:00Z"* ]]; then
      echo "1672876800"
    elif [[ $* == *"-d 2023-01-10T00:00:00Z"* ]]; then
      echo "1673308800"
    else
      echo "1673481600" # 2023-01-12
    fi
  else
    echo "2023-01-12T00:00:00Z"
  fi
}

# Load the source file
source "$REPO_ROOT/src/github.sh"

export GITHUB_TOKEN="fake-token"
export GITHUB_API_URL="https://api.github.com/repos/user/repo"
export BASE_BRANCHES=("main")

errors=0

run_test() {
  local threshold="$1"
  local expected="$2"
  local output
  output=$(github::get_inactive_branches "$threshold")
  if [ "$output" = "$expected" ]; then
    echo "✅ get_inactive_branches $threshold"
  else
    echo "❌ get_inactive_branches $threshold: expected '$expected' got '$output'"
    errors=$((errors+1))
  fi
}

run_test 7 "feature/old"
run_test 1 $'feature/old\nfeature/new'
run_test 30 "feature/old"

if [ $errors -eq 0 ]; then
  echo "All tests passed"
else
  echo "$errors tests failed"
  exit 1
fi
