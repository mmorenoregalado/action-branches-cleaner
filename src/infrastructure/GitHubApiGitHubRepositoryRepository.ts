import * as github from '@actions/github'
import {GitHubRepositoryRepository} from '../domain/GitHubRepositoryRepository'
import {Branch} from '../domain/GitHubRepository'

export class GitHubApiGitHubRepositoryRepository
  implements GitHubRepositoryRepository
{
  private gitHub
  private repo: string
  private owner: string

  constructor({
    token,
    repo,
    owner,
  }: {
    token: string,
    repo: string,
    owner: string,
  }) {
    this.repo = repo
    this.owner = owner
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

  async deleteBranches(branches: string[]): Promise<void> {
    const {owner, repo} = this

    for (const branch of branches) {
      await this.gitHub.rest.git.deleteRef({
        owner,
        repo,
        ref: `heads/${branch}`
      })
    }
  }
}
