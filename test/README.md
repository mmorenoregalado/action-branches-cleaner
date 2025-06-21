# Tests for Branches Cleaner GitHub Action

This directory contains the automated tests for the "Branches Cleaner" GitHub Action. The suite includes unit, integration and functional tests to ensure the action works correctly.

## Test Structure

```
test/
├── bats/                   # Unit tests with Bats
│   ├── github_test.bats    # Tests for github.sh
│   ├── cleanup_test.bats   # Tests for cleanup.sh
│   ├── main_test.bats      # Tests for main.sh
│   └── integration_test.bats # Integration tests
├── docker/                 # Integration tests using Docker
│   ├── Dockerfile.test     # Docker file to run tests
│   ├── docker-compose.yml  # Docker Compose configuration
│   ├── mock_github_api.sh  # Mock GitHub API
│   └── run_tests.sh        # Test execution script
├── functional/             # Functional tests
│   └── workflow-test.yml   # GitHub Actions workflow
├── test_helper.bash        # Helper functions for Bats
├── inactive_branches_test.sh # Specific test for inactive branch detection
└── README.md               # This documentation
```

## Types of Tests

### 1. Unit Tests (Bats)

The unit tests use [Bats (Bash Automated Testing System)](https://github.com/bats-core/bats-core) to test each function in isolation:

- `github_test.bats`: Tests the functions in `github.sh` that interact with the GitHub API.
- `cleanup_test.bats`: Tests the functions in `cleanup.sh` for deleting different types of branches.
- `main_test.bats`: Tests the main logic in `main.sh`.
- `integration_test.bats`: Combined tests across modules.

### 2. Integration Tests (Docker)

Integration tests use Docker to simulate an environment close to GitHub Actions:

- `Dockerfile.test`: Sets up a container similar to the GitHub Actions environment.
- `mock_github_api.sh`: Mocks GitHub API responses without real requests.
- `run_tests.sh`: Executes different test scenarios inside the container.

### 3. Specific Tests

- `inactive_branches_test.sh`: Specific test for the `github::get_inactive_branches` function that detects inactive branches.

### 4. Functional Tests (GitHub Actions)

- `workflow-test.yml`: Defines a GitHub Actions workflow to test the action in a real environment.

## Running the Tests

### Unit Tests with Bats

```bash
# Install Bats (if not installed)
sudo apt-get install bats

# Run all Bats tests
bats test/bats

# Run a specific test file
bats test/bats/github_test.bats
```

### Integration Tests with Docker

```bash
# Build and run the tests with Docker Compose
cd test/docker
docker-compose up --build
```

### Specific Test for Inactive Branches

```bash
# Run the specific test
chmod +x test/inactive_branches_test.sh
./test/inactive_branches_test.sh
```

### Functional Tests on GitHub Actions

Functional tests run automatically in GitHub Actions when:

1. Pushing to the `main` branch
2. Opening a pull request against the `main` branch

## CI Workflow

The project includes a GitHub Actions workflow to run all tests in continuous integration. See `.github/workflows/test.yml` for details.

## Contributing to the Tests

When contributing new features or fixes to the action, be sure to:

1. Add unit tests for new features or fixes.
2. Verify that all tests pass before submitting a pull request.
3. Update existing tests if necessary to reflect expected behavior changes.

## Troubleshooting

If the tests fail:

1. Verify that mocks and stubs correctly reflect the expected behavior.
2. Check that the tested functions do not have unexpected side effects.
3. For Docker tests, ensure the image builds correctly.
4. For functional tests with GitHub Actions, verify the token permissions.

## References

- [Bats Testing Framework](https://github.com/bats-core/bats-core)
- [ShellCheck](https://www.shellcheck.net/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker Compose](https://docs.docker.com/compose/)
