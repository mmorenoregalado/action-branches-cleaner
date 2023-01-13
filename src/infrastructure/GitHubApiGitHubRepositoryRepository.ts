import * as github from '@actions/github'
import {GitHubRepositoryRepository} from '../domain/GitHubRepositoryRepository'
import {Branch} from '../domain/GitHubRepository'
import {GithubPullRequest} from '../domain/GitHubPullRequest'

export class GitHubApiGitHubRepositoryRepository
  implements GitHubRepositoryRepository
{
  private gitHub
  private repo: string
  private owner: string

  constructor({
    token,
    repo,
    owner
  }: {
    token: string
    repo: string
    owner: string
  }) {
    this.repo = repo
    this.owner = owner
    this.gitHub = github.getOctokit(token)
  }

  async branches(): Promise<Branch[]> {
    const {repo, owner} = this
    const {data} = await this.gitHub.rest.repos.listBranches({
      owner,
      repo,
      protected: false
    })
    return data.map<Branch>(branch => ({name: branch.name}))
  }

  async listPullRequests(): Promise<GithubPullRequest[]> {
    const {repo, owner} = this
    const {data} = await this.gitHub.rest.pulls.list({
      owner,
      repo,
      state: 'closed',
      base: 'main',
      sort: 'updated',
      direction: 'desc'
    })
    return data as unknown as GithubPullRequest[]
  }

  async deleteBranches(branches: Branch[]): Promise<void> {
    const {owner, repo} = this

    for (const branch of branches) {
      await this.gitHub.rest.git.deleteRef({
        owner,
        repo,
        ref: `heads/${branch}`
      })
    }
  }

  mergedBranches(
    branches: Branch[],
    pullRequests: GithubPullRequest[]
  ): Branch[] {
    return branches.filter(branch => {
      return pullRequests
        .filter(pull => {
          return pull.merged_at !== null
        })
        .filter(pull => pull.head.ref === branch.name)
    })
  }
}
