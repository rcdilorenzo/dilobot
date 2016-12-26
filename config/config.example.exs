use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :slack,
  api_token: "<slack-api-token>"

config :dilo_bot,
  id: "<slack-bot-id>",
  reports_channel: "<posting-channel-id>"

config :dilo_bot,
  ww_keys: [:ww_school_id, :ww_school, :ww_username, :ww_password, :ww_mapping],
  ww_school_id: "<wordly-wise-school-id>",
  ww_school: "<wordly-wise-school-name>",
  ww_username: "<username>",
  ww_password: "<password>",
  ww_mapping: "<slack-usernames-to-wordly-wise-users-in-json-encoded-form>"

# Mapping Example ^
# "{\"my-slack-username\": [\"Last, First\", \"Wordly Wise, User\"]}"
