#!/usr/bin/env bats

load '../test_helper.bash'

# Setup for all tests
setup() {
  # Load the scripts with the correct path
  source "${BATS_TEST_DIRNAME}/../../src/cleanup.sh"
  
  # Mock the github::delete_branch function
  github::delete_branch() {
    local branch=$1
    if [[ " ${BASE_BRANCHES[*]} " == *" $branch "* ]]; then
      echo "PROTECTED: Not deleting base branch $branch"
    else
      echo "DELETED: Branch $branch removed"
    fi
  }
  
  # Mock github::get_inactive_branches
  github::get_inactive_branches() {
    local days=$1
    echo "feature/old"
    echo "feature/stale"
  }
  
  # Required environment variables
  export BASE_BRANCHES=("main" "develop")
}

@test "cleanup::delete_merged_branches removes all merged branches" {
  # Prepare test data
  local merged_branches=$'feature/merged1\nfeature/merged2\nmain'
  
  # Run the function under test
  run cleanup::delete_merged_branches "$merged_branches"
  
  # Assertions
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/merged1"* ]]
  [[ "$output" == *"feature/merged2"* ]]
  [[ "$output" == *"DELETED: Branch feature/merged1 removed"* ]]
  [[ "$output" == *"DELETED: Branch feature/merged2 removed"* ]]
  [[ "$output" == *"PROTECTED: Not deleting base branch main"* ]]
}

@test "cleanup::delete_unmerged_branches removes closed unmerged branches" {
  # Prepare test data
  local unmerged_branches=$'feature/unmerged1\nfeature/unmerged2'
  
  # Run the function under test
  run cleanup::delete_unmerged_branches "$unmerged_branches"
  
  # Assertions
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/unmerged1"* ]]
  [[ "$output" == *"feature/unmerged2"* ]]
  [[ "$output" == *"DELETED: Branch feature/unmerged1 removed"* ]]
  [[ "$output" == *"DELETED: Branch feature/unmerged2 removed"* ]]
}

@test "cleanup::delete_inactive_branches removes inactive branches" {
  # Run the function under test
  run cleanup::delete_inactive_branches "7"
  
  # Assertions
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/old"* ]]
  [[ "$output" == *"feature/stale"* ]]
  [[ "$output" == *"DELETED: Branch feature/old removed"* ]]
  [[ "$output" == *"DELETED: Branch feature/stale removed"* ]]
} 