import {Branch} from './GitHubRepository'
import {GithubPullRequest} from './GitHubPullRequest'

export interface GitHubRepositoryRepository {
  branches(): Promise<Branch[]>
  mergedBranches(
    branches: Branch[],
    pullRequests: GithubPullRequest[]
  ): Branch[]
  deleteBranches(branches: Branch[]): Promise<void>
  listPullRequests(): Promise<GithubPullRequest[]>
}
