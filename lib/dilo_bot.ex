defmodule DiloBot do
  use Application
  import Application, only: [get_env: 2]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Slack.Bot, [DiloBot.Bot, [], api_token()]),
      supervisor(DiloBot.Repo, []),
      Plug.Adapters.Cowboy.child_spec(:http, DiloBot.Router, [],
        [port: get_env(:dilo_bot, :port)])
    ]

    opts = [strategy: :one_for_one, name: DiloBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def api_token do
    get_env(:slack, :api_token)
  end
end
