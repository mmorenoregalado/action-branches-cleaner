export interface GitHubBranch {
  name: string
  commit: Commit
  protected: boolean
}

interface Commit {
  sha: string
  url: string
}
