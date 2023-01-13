import { GitHubApiGitHubRepositoryRepository } from "../../src/infrastructure/GitHubApiGitHubRepositoryRepository";
import { config } from "../../src/action_config";
import { GitHubApiBranchMother } from '../domain/GitHubApiBranchMother';
import { NockRepository } from './NockRepository';

const repository = new GitHubApiGitHubRepositoryRepository({
  token: config.github_token,
  repo: config.repo,
  owner: config.owner
});

describe("GitHubRepositoryRepository", () => {
  it("should get a branches list", async () => {
    const someBranch = GitHubApiBranchMother.create();
    NockRepository.sendGetRequestListBranches({statusCode:200, response: [someBranch]})
    const branches = await repository.branches();

    branches.forEach(branch => {
      expect(branch).toEqual(expect.objectContaining({ name: someBranch.name }));
      expect(branch).not.toEqual(expect.objectContaining({ protected: someBranch.protected }));
    });
  });

});
