import dotenv from 'dotenv'
dotenv.config()
export interface ActionConfig {
  github_token: string
  repo: string
  owner: string
}

export const config: ActionConfig = {
  github_token: process.env.GITHUB_TOKEN as string,
  repo: process.env.REPOSITORY_NAME as string,
  owner: process.env.REPOSITORY_OWNER as string
}
