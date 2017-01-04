use Mix.Config

config :dilo_bot,
  ecto_repos: [DiloBot.Repo]

config :dilo_bot, DiloBot.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "dilo_bot_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :porcelain,
  driver: Porcelain.Driver.Basic

config :slack,
  api_token: "<slack-api-token>"

config :dilo_bot,
  bot_name: "<slackbot-name>",
  id: "<slack-bot-id>",
  reports_channel: "<posting-channel-id>",
  port: 4001,
  auth: [
    username: "<username>",
    password: "<password>",
    realm: "<why-auth>"
  ]

config :dilo_bot,
  ww_keys: [:ww_school_id, :ww_school, :ww_username, :ww_password],
  ww_school_id: "<wordly-wise-school-id>",
  ww_school: "<wordly-wise-school-name>",
  ww_username: "<username>",
  ww_password: "<password>",
  ww_channel_mapping: %{a_slack_channel_name: "<wordly-wise-name>"}
