#!/bin/bash
set -e

# Mock GitHub API using a local server
# Create a small simulated HTTP API with files and netcat

# Directory to store the API responses
API_DIR="/tmp/github_api"
mkdir -p "${API_DIR}/repos/test-user/test-repo"

# Create responses for each endpoint
echo '[{"head": {"ref": "feature/test1"}}, {"head": {"ref": "feature/test2"}, "merged_at": "2023-01-01"}]' > "${API_DIR}/repos/test-user/test-repo/pulls_closed"
echo '[{"name": "main"}, {"name": "develop"}, {"name": "feature/old"}, {"name": "feature/new"}]' > "${API_DIR}/repos/test-user/test-repo/branches"
echo '{"commit": {"commit": {"committer": {"date": "2020-01-01T00:00:00Z"}}}}' > "${API_DIR}/repos/test-user/test-repo/branch_old"
echo '{"commit": {"commit": {"committer": {"date": "2023-01-10T00:00:00Z"}}}}' > "${API_DIR}/repos/test-user/test-repo/branch_new"

# Function to simulate curl using local files
function mock_curl() {
  local url="$*"
  
  # Define API_DIR in case it's not available in the environment
  local API_DIR="${API_DIR:-/tmp/github_api}"
  
  # If MOCK_ERROR is defined and set to 1, simulate an error
  if [[ -n "${MOCK_ERROR:-}" && "${MOCK_ERROR:-}" -eq 1 ]]; then
    echo "MOCK API ERROR: Simulating API error" >&2
    return 1
  fi
  
  # Extract the command (GET, DELETE, etc.) and the URL
  local command
  local endpoint
  command=$(echo "$url" | grep -o -E '(GET|DELETE|POST|PUT)' || echo "GET")
  endpoint=$(echo "$url" | grep -o -E 'https://api.github.com/repos/[^ ]+')
  endpoint=${endpoint#https://api.github.com/}
  
  echo "MOCK API REQUEST: $command $endpoint" >&2
  
  # Simulate different endpoints
  case "$endpoint" in
    "repos/test-user/test-repo/pulls?state=closed")
      cat "${API_DIR}/repos/test-user/test-repo/pulls_closed"
      ;;
    "repos/test-user/test-repo/branches?protected=false")
      cat "${API_DIR}/repos/test-user/test-repo/branches"
      ;;
    *"branches/feature/old"*)
      cat "${API_DIR}/repos/test-user/test-repo/branch_old"
      ;;
    *"branches/feature/new"*)
      cat "${API_DIR}/repos/test-user/test-repo/branch_new"
      ;;
    *"git/refs/heads/"*)
      if [[ "$command" == "DELETE" ]]; then
        local branch
        branch=${endpoint##*/heads/}
        echo "MOCK API: Deleted branch $branch" >&2
        echo '{}'
      else
        echo '{}'
      fi
      ;;
    *)
      echo "MOCK API: Unknown endpoint $endpoint" >&2
      echo '{}'
      ;;
  esac
}

# Export the function so it can be used instead of curl
export -f mock_curl

# Replace the curl function with our mocked version
function curl() {
  mock_curl "$@"
}
export -f curl

# Function to simulate date
function date() {
  if [[ "$*" == *"--date="* ]]; then
    # Extract the number of days
    if [[ "$*" =~ --date=([0-9]+)\ day\ ago ]]; then
      local days=${BASH_REMATCH[1]}
      echo "2023-01-$((12 - days))T00:00:00Z"
    else
      echo "2023-01-12T00:00:00Z"
    fi
  elif [[ "$*" == *"-d "* ]]; then
    # Convert date to timestamp
    if [[ "$*" =~ -d\ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
      local year=${BASH_REMATCH[1]:0:4}
      local month=${BASH_REMATCH[1]:5:2}
      local day=${BASH_REMATCH[1]:8:2}
      echo $(( (year - 1970) * 365 * 24 * 3600 + month * 30 * 24 * 3600 + day * 24 * 3600 ))
    else
      echo "1672531200" # Default value
    fi
  else
    echo "2023-01-12T00:00:00Z"
  fi
}
export -f date 