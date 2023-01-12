import { GitHubRepositoryRepository } from "../domain/GitHubRepositoryRepository";

export class CleanerBranches {
  constructor(private readonly repository: GitHubRepositoryRepository) {
  }

  async run({ignoredBranches}: {ignoredBranches: string[]}): Promise<void> {
    const branches = await this.repository.branches();
    const mergedBranches = await this.repository.mergedBranches(branches);
    const filteredBranches = this.filterWithoutNullsAndIgnoredBranches(mergedBranches, ignoredBranches)

    return this.repository.deleteBranches(filteredBranches);
  }

  private filterWithoutNullsAndIgnoredBranches(branches: string[], ignoredBranches: string[]): string[] {
    return branches
    .filter(branch => branch !== null)
     .filter(branch => !ignoredBranches.includes(branch))
  }
}
