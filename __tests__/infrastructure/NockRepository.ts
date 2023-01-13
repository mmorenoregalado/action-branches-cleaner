import nock from "nock";

import { GitHubBranch } from "../../src/domain/GitHubBranch";
import { config } from "../../src/action_config";

const urlApi = "https://api.github.com";

export class NockRepository {
  static sendGetRequestListBranches({ statusCode, response }: { statusCode: number, response: GitHubBranch[] }): void {
    const url = `/repos/${config.owner}/${config.repo}/branches?protected=false`;
    nock(urlApi).
      get(url).reply(statusCode, response);
  }
}
