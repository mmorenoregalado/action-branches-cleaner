#!/usr/bin/env bats

load '../test_helper.bash'

# Setup for all tests
setup() {
  # Mock github::get_branches
  github::get_branches() {
    echo "feature/old"
    echo "feature/new"
    echo "main"
  }

  # Mock curl
  curl() {
    if [[ $* == *"branches/feature/old"* ]]; then
      echo '{"commit": {"commit": {"committer": {"date": "2020-01-01T00:00:00Z"}}}}'
    elif [[ $* == *"branches/feature/new"* ]]; then
      echo '{"commit": {"commit": {"committer": {"date": "2023-01-10T00:00:00Z"}}}}'
    elif [[ $* == *"branches/main"* ]]; then
      echo '{"commit": {"commit": {"committer": {"date": "2023-01-11T00:00:00Z"}}}}'
    else
      echo "Unexpected endpoint: $*" >&2
      echo '{}'
    fi
  }

  # Mock date
  date() {
    if [[ $* == *"--date="* ]]; then
      if [[ $* == *"--date=7 day ago"* ]]; then
        echo "2023-01-05T00:00:00Z"
      else
        local days=$(echo "$*" | sed -n 's/.*--date=\([0-9]\+\).*/\1/p')
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

  # Cargar el código fuente y configurar variables
  source "${BATS_TEST_DIRNAME}/../../src/github.sh"
  export GITHUB_TOKEN="fake-token"
  export GITHUB_API_URL="https://api.github.com/repos/user/repo"
  export BASE_BRANCHES=("main")
}

@test "get_inactive_branches with threshold of 7 days" {
  # Threshold of 7 days (only feature/old should be inactive)
  run github::get_inactive_branches "7"
  
  # Verificaciones
  [ "$status" -eq 0 ]
  [ "$output" = "feature/old" ]
}

@test "get_inactive_branches with threshold of 1 day" {
  # Threshold of 1 day (feature/old and feature/new should be inactive)
  run github::get_inactive_branches "1"
  
  # Verificaciones
  [ "$status" -eq 0 ]
  [ "$output" = $'feature/old\nfeature/new' ]
}

@test "get_inactive_branches with threshold of 30 days" {
  # Threshold of 30 days (only feature/old should be inactive)
  run github::get_inactive_branches "30"
  
  # Assertions
  [ "$status" -eq 0 ]
  [ "$output" = "feature/old" ]
} 