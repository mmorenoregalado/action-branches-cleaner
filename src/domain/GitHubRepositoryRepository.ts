import {Branch} from "./GitHubRepository";

export interface GitHubRepositoryRepository {
  branches(): Promise<Branch[]>;
  mergedBranches(branches: Branch[]): Promise<string[]>;
  deleteBranches(branches: string[]): Promise<void>;
}
