import { GitHubBranch } from "../../src/domain/GitHubBranch";
import { faker } from "@faker-js/faker";

export class GitHubApiBranchMother {
  static create(params?: Partial<GitHubBranch>): GitHubBranch {
    return {
      name: faker.random.word(),
      commit: {
        sha: faker.datatype.hexadecimal(),
        url: faker.internet.url()
      },
      protected: faker.datatype.boolean(),
      ...params
    }
  }
}
