import {faker} from '@faker-js/faker'

export type GitHubPullRequestFaker = {
  title: string
  merged_at: string | null
  head: {
    ref: string
  }
}

export class GithubPullRequestMother {
  static create(
    params?: Partial<GitHubPullRequestFaker>
  ): GitHubPullRequestFaker {
    return {
      title: faker.name.jobTitle(),
      merged_at: faker.datatype.datetime().toString(),
      head: {
        ref: faker.git.branch()
      },
      ...params
    }
  }
}
