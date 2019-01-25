defmodule DiloBot do
  use Application
  import Application, only: [get_env: 2]
  import Plug.Cowboy, only: [child_spec: 1]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    port = get_env(:dilo_bot, :port)

    children = [
      supervisor(DiloBot.Repo, []),
      child_spec(scheme: :http, plug: DiloBot.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: DiloBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def api_token do
    get_env(:slack, :bot_access_token)
  end
end
