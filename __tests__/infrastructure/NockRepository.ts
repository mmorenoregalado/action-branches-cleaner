import nock from 'nock'

import {GitHubBranch} from '../../src/domain/GitHubBranch'
import {config} from '../../src/action_config'
import {GitHubPullRequestFaker} from '../domain/GithubPullRequestMother'

const urlApi = 'https://api.github.com'
const uriRepoBase = `/repos/${config.owner}/${config.repo}`

export class NockRepository {
  static sendGetRequestListBranches({
    statusCode,
    response
  }: {
    statusCode: number
    response: GitHubBranch[]
  }): void {
    const url = `${uriRepoBase}/branches?protected=false`
    nock(urlApi).get(url).reply(statusCode, response)
  }

  static sendGetPullRequestList({
    statusCode,
    response
  }: {
    statusCode: number
    response: GitHubPullRequestFaker[]
  }): void {
    const url = `${uriRepoBase}/pulls?state=closed&base=main&sort=updated&direction=desc`
    nock(urlApi).get(url).reply(statusCode, response)
  }
}
