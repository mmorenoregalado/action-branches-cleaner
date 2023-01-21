import * as core from '@actions/core'
import * as yaml from 'js-yaml'
import * as github from '@actions/github'

import {GitHubApiGitHubRepositoryRepository} from './infrastructure/GitHubApiGitHubRepositoryRepository'
import {CleanerBranches} from './application/CleanerBranches'
import {config} from './action_config'

export async function run(): Promise<void> {
  try {
    const repository = new GitHubApiGitHubRepositoryRepository({
      token: core.getInput('GITHUB_TOKEN') || config.github_token,
      repo: github.context.repo.repo || config.repo,
      owner: github.context.repo.owner || config.owner
    })

    const cleaner = new CleanerBranches(repository)
    cleaner.run({ignoredBranches: ignoreBranches()})
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)
  }
}

function ignoreBranches(): string[] {
  const defaultBranches: string[] = ['master', 'main']

  try {
    const customBranches = yaml.load(
      core.getInput('ignore_branches')
    ) as string[]

    if (!customBranches) {
      return defaultBranches
    }

    return [...defaultBranches, ...customBranches]
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)

    return defaultBranches
  }
}

run()
