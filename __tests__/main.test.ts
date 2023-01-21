import {RunOptions, RunTarget} from 'github-action-ts-run-api'
import {run} from '../src/main'
import {NockRepository} from './infrastructure/NockRepository'
import {GitHubApiBranchMother} from './domain/GitHubApiBranchMother'
import {GithubPullRequestMother} from './domain/GithubPullRequestMother'
import nock from 'nock'

describe('main file', () => {
  beforeAll(() => {
    nock.cleanAll()
  })
  it('should execute action when init action', async () => {
    NockRepository.sendDeletePullRequestList()
    const someBranch = GitHubApiBranchMother.create()
    NockRepository.sendGetRequestListBranches({
      statusCode: 200,
      response: [someBranch]
    })

    const pullsMother = GithubPullRequestMother.create()
    NockRepository.sendGetPullRequestList({
      statusCode: 200,
      response: [pullsMother]
    })

    const action = await RunTarget.syncFn(run, 'action.yml')
    const result = action.run(
      RunOptions.create({
        env: {
          GITHUB_TOKEN: process.env.GITHUB_TOKEN,
          GITHUB_REPOSITORY: process.env.GITHUB_REPOSITORY
        }
      })
    )

    expect(result.isSuccess).toBeTruthy()
    expect(result.exitCode).toBeUndefined()
    expect(result.warnings).toHaveLength(0)
  })
})
