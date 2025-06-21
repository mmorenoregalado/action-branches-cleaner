#!/bin/bash
set -e

echo "===== STARTING DOCKER TESTS FOR BRANCHES CLEANER ====="

# Initialize counters for the results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Load the GitHub API mock
echo "Loading GitHub API mock..."
# shellcheck disable=SC1091
source "/github/workspace/test/docker/mock_github_api.sh"

# Function to run a test and check its output
run_test() {
  local test_name="$1"
  local cmd="$2"
  local expected_output="$3"
  
  echo ""
  echo "===== Running test: $test_name ====="
  echo "Command: $cmd"
  echo ""
  
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  
  # Execute the command and capture its output
  local output
  local exit_code
  output=$(eval "$cmd")
  exit_code=$?
  
  # Check whether the output contains the expected text
  if [ $exit_code -eq 0 ] && [[ "$output" == *"$expected_output"* ]]; then
    echo "✅ Test passed: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ Test failed: $test_name"
    echo "Actual output:"
    echo "$output"
    echo "Expected to contain:"
    echo "$expected_output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 1: Basic test with default base branches
run_test "Basic test" \
  "/github/workspace/entrypoint.sh 'main,develop' '7' 'fake-token'" \
  "Deleting merged branch: feature/test2"

# Test 2: Test with custom day threshold
run_test "Custom day threshold" \
  "/github/workspace/entrypoint.sh 'main,develop' '1' 'fake-token'" \
  "Deleting inactive branch: feature/old"

# Test 3: Test protecting a specific branch
run_test "Specific branch protection" \
  "/github/workspace/entrypoint.sh 'main,develop,feature/test2' '7' 'fake-token'" \
  "Deleting not merged branch: feature/test1"

# Test 4: Ensure the script handles errors correctly (simulated curl)
run_test "Error handling" \
  "MOCK_ERROR=1 /github/workspace/entrypoint.sh 'main' '7' 'fake-token' || echo 'Error detectado correctamente'" \
  "Error detectado correctamente"

# Run Bats tests if available
if command -v bats &> /dev/null; then
  echo ""
  echo "===== Running Bats tests ====="
  cd /github/workspace && bats /github/workspace/test/bats
fi

# Summary of results
echo ""
echo "===== DOCKER TEST SUMMARY ====="
echo "Total tests: $TESTS_TOTAL"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

# Exit with the proper status code
if [ $TESTS_FAILED -eq 0 ]; then
  echo "✅ All tests passed successfully"
  exit 0
else
  echo "❌ Some tests failed"
  exit 1
fi 