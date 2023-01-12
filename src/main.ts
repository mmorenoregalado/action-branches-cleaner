import * as core from '@actions/core'
import * as yaml from 'js-yaml'

import {GitHubApiGitHubRepositoryRepository} from './infrastructure/GitHubApiGitHubRepositoryRepository'
import {GitHubRepositoryRepository} from './domain/GitHubRepositoryRepository'

async function run({
  repository
}: {
  repository: GitHubRepositoryRepository
}): Promise<void> {
  try {
    const branches = await repository.branches()
    const mergedBranches = await repository.mergedBranches(branches)
    repository.deleteBranches(mergedBranches)
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

const repository = new GitHubApiGitHubRepositoryRepository({
  token: core.getInput('GITHUB_TOKEN'),
  ignoreBranches: ignoreBranches()
})

run({repository})
