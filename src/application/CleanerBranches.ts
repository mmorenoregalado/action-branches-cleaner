import { GitHubRepositoryRepository } from "../domain/GitHubRepositoryRepository";
import { Branch } from "../domain/GitHubRepository";

export class CleanerBranches {
  constructor(private readonly repository: GitHubRepositoryRepository) {
  }

  async run({ignoredBranches}: {ignoredBranches: string[]}): Promise<void> {
    const branches = await this.repository.branches();
    const pullRequests = await this.repository.listPullRequests();
    const mergedBranches = this.repository.mergedBranches(branches, pullRequests);
    const filteredBranches = this.filterWithoutNullsAndIgnoredBranches(mergedBranches, ignoredBranches)

    return this.repository.deleteBranches(filteredBranches);
  }

  private filterWithoutNullsAndIgnoredBranches(branches: Branch[], ignoredBranches: string[]): Branch[] {
    return branches
     .filter(branch => !ignoredBranches.includes(branch.name))
  }
}
