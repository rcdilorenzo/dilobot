defmodule DiloBot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Slack.Bot, [DiloBot.Bot, [], api_token()]),
      supervisor(DiloBot.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: DiloBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def api_token do
    Application.get_env(:slack, :api_token)
  end
end
