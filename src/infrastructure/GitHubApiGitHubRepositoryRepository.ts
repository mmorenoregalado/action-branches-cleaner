import {GitHubRepositoryRepository} from '../domain/GitHubRepositoryRepository'
import * as github from '@actions/github'
import {Branch} from '../domain/GitHubRepository'

export class GitHubApiGitHubRepositoryRepository
  implements GitHubRepositoryRepository
{
  private gitHub
  private repo: string
  private owner: string
  private ignoreBranches: string[]

  constructor({
    token,
    ignoreBranches
  }: {
    token: string
    ignoreBranches: string[]
  }) {
    this.repo = github.context.repo.repo
    this.owner = github.context.repo.owner
    this.ignoreBranches = ignoreBranches
    this.gitHub = github.getOctokit(token)
  }

  async branches(): Promise<Branch[]> {
    const {repo, owner} = this
    const {data} = await this.gitHub.rest.repos.listBranches({owner, repo})
    return data.map<Branch>(branch => ({name: branch.name}))
  }

  async mergedBranches(branches: Branch[]): Promise<string[]> {
    const {owner, repo} = this
    return (await Promise.all(
      branches.map(async branch => {
        const {data} = await this.gitHub.rest.pulls.list({
          owner,
          repo,
          state: 'closed',
          base: branch.name
        })
        return data ? branch.name : null
      })
    )) as string[]
  }

  filterWithoutNullsAndIgnoredBranches(branches: string[]): string[] {
    return branches
      .filter(branch => branch !== null)
      .filter(branch => !this.ignoreBranches.includes(branch))
  }

  async deleteBranches(branches: string[]): Promise<void> {
    const branchesToDelete = this.filterWithoutNullsAndIgnoredBranches(branches)
    const {owner, repo} = this

    for (const branch of branchesToDelete) {
      await this.gitHub.rest.git.deleteRef({
        owner,
        repo,
        ref: `heads/${branch}`
      })
    }
  }
}
