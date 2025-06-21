#!/usr/bin/env bash

# Helper for debugging and common messages
debug() {
  if [ "${BATS_DEBUG:-0}" -eq 1 ]; then
    echo "DEBUG: $*" >&3
  fi
}

# Helper function to compare expected and actual output
assert_output_contains() {
  local expected="$1"
  if [[ "$output" != *"$expected"* ]]; then
    echo "Output does not contain '$expected'" >&2
    echo "Actual output: $output" >&2
    return 1
  fi
}

assert_output_not_contains() {
  local unexpected="$1"
  if [[ "$output" == *"$unexpected"* ]]; then
    echo "Output contains '$unexpected' when it shouldn't" >&2
    echo "Actual output: $output" >&2
    return 1
  fi
}

# Log information about the test run environment
setup_file() {
  echo "Starting Bats test run at $(date)" >&3
  echo "System: $(uname -a)" >&3
}

teardown_file() {
  echo "Finishing Bats test run at $(date)" >&3
}

# Function to create a temporary structure for tests
create_test_branches() {
  local repo_dir="$1"
  
  mkdir -p "$repo_dir"
  cd "$repo_dir"
  
  git init -q
  git config --local user.email "test@example.com"
  git config --local user.name "Test User"
  
  # Create main branch
  echo "# Test Repository" > README.md
  git add README.md
  git commit -q -m "Initial commit"
  
  # Create branches for tests
  git checkout -q -b feature/test1
  echo "Feature 1" > feature1.txt
  git add feature1.txt
  GIT_COMMITTER_DATE="2020-01-01T00:00:00Z" git commit -q --date="2020-01-01T00:00:00Z" -m "Feature 1 commit"
  
  git checkout -q -b feature/test2
  echo "Feature 2" > feature2.txt
  git add feature2.txt
  git commit -q -m "Feature 2 commit"
  
  git checkout -q master
}

# Clean up after the tests
cleanup_test_repo() {
  local repo_dir="$1"
  if [ -d "$repo_dir" ]; then
    rm -rf "$repo_dir"
  fi
} 