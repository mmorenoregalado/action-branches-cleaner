import { faker } from "@faker-js/faker";
import { GithubPullRequest, Links } from "../../src/domain/GitHubPullRequest";

export class GithubPullRequestMother {
  static create(params?: Partial<GithubPullRequest>): Partial<GithubPullRequest> {
    return {
      url: faker.internet.url(),
      id: faker.datatype.number(),
      node_id: faker.datatype.uuid(),
      html_url: faker.random.word(),
      diff_url: faker.internet.url(),
      patch_url: faker.internet.url(),
      issue_url: faker.internet.url(),
      number: faker.datatype.number(),
      state: 'closed',
      locked: faker.datatype.boolean(),
      title: faker.name.jobTitle(),
      created_at: faker.datatype.datetime().toString(),
      updated_at: faker.datatype.datetime().toString(),
      closed_at: faker.datatype.datetime().toString(),
      merged_at: faker.datatype.datetime().toString(),
      ...params
    }
  }
}
