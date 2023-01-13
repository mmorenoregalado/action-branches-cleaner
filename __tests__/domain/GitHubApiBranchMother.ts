import { GitHubBranch } from "../../src/domain/GitHubBranch";
import { faker } from "@faker-js/faker";

export class GitHubApiBranchMother {
  static create(params?: Partial<GitHubBranch>): GitHubBranch {
    return {
      name: faker.git.branch(),
      commit: {
        sha: faker.git.shortSha(),
        url: faker.internet.url()
      },
      protected: faker.datatype.boolean(),
      ...params
    }
  }
}
