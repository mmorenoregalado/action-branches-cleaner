import { GitHubApiGitHubRepositoryRepository } from "../../src/infrastructure/GitHubApiGitHubRepositoryRepository";
import { config } from "../../src/action_config";
import { GitHubApiBranchMother } from "../domain/GitHubApiBranchMother";
import { NockRepository } from "./NockRepository";
import { GithubPullRequestMother } from "../domain/GithubPullRequestMother";
import { GithubPullRequest } from "../../src/domain/GitHubPullRequest";

const repository = new GitHubApiGitHubRepositoryRepository({
  token: config.github_token,
  repo: config.repo,
  owner: config.owner
});

describe("GitHubRepositoryRepository", () => {
  it("should get a branches list", async () => {
    const someBranch = GitHubApiBranchMother.create();
    NockRepository.sendGetRequestListBranches({ statusCode: 200, response: [someBranch] });
    const branches = await repository.branches();

    branches.forEach(branch => {
      expect(branch).toEqual(expect.objectContaining({ name: someBranch.name }));
      expect(branch).not.toEqual(expect.objectContaining({ protected: someBranch.protected }));
    });
  });

  it("should get pulls", async () => {
    const pullsMother = GithubPullRequestMother.create();
    NockRepository.sendGetPullRequestList({ statusCode: 200, response: [pullsMother] });
    const pulls = await repository.listPullRequests();
    expect(pulls.length > 0).toBeTruthy();
  });

  describe("Branches Mergeds", () => {
    it("should not merged", () => {
      const branch = GitHubApiBranchMother.create();
      const pull = GithubPullRequestMother.create({
        merged_at: null,
        head: { ref: branch.name }
      }) as unknown as GithubPullRequest;
      const mergeds = repository.mergedBranches([branch], [pull]);

      expect(mergeds.length === 0).toBeTruthy();
    });

    it("should some branch merged", () => {
      const branch = GitHubApiBranchMother.create();
      const otherBranch = GitHubApiBranchMother.create();
      const pull = GithubPullRequestMother.create({
        merged_at: null,
        head: { ref: branch.name }
      }) as unknown as GithubPullRequest;
      const pullMerged = GithubPullRequestMother.create({
        head: { ref: otherBranch.name }
      }) as unknown as GithubPullRequest;

      const merges = repository.mergedBranches([branch, otherBranch], [pull, pullMerged]);

      expect(merges.length > 0).toBeTruthy();
      merges.forEach( merged => {
        expect(merged.name).toEqual(pullMerged.head.ref)
        expect(merged.name).toEqual(otherBranch.name)
      })
    });
  });

});
