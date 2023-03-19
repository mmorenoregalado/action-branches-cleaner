# Branches Cleaner Github Action

<img src="assets/branche_cleaner.svg" alt="github action icon" width="300px" height="300px">


This Github Action automatically deletes merged or unmerged branches in a repository. You can specify the base branches or protected branches that should not be deleted.

## Inputs
### `base_branches`

***Required***. Comma-separated string of the base branches that you want to keep. For example: `main,develop`.

### `github_token`
***Required***. Token to authenticate with the GitHub API.

## Usage
To use the Branches Cleaner Github Action, add the following code to your Github Actions workflow:

```` yaml
name: Branches Cleaner

on:
  schedule:
    - cron: "0 0 * * *"

jobs:
  cleanup-branches:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Branches Cleaner
        uses: your-username/branches-cleaner@v1
        with:
          base_branches: develop,master
          github_token: ${{ secrets.GITHUB_TOKEN }}

````
This example uses a schedule trigger to run the action every day at midnight. The base_branches input takes a comma-separated list of base branches or protected branches that should

## Contributing
This action is open to contributions. If you find any issues or bugs, feel free to open an issue or pull request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
