defmodule DiloBot.SlackRouter do
  use Plug.Router
  use Plug.Builder
  use DiloBot.Web.Render

  alias DiloBot.Command.GenerateWW, as: GenerateWW

  require IEx
  import Application, only: [get_env: 2]

  plug Plug.Logger, log: :debug
  plug :fetch_query_params
  plug :merge_body_params
  plug :verify_slack
  plug :match
  plug :dispatch

  post "/s/ww" do
    case GenerateWW.parse_params(conn.params) do
      {:ok, config} ->
        Task.async(fn -> GenerateWW.process(config) end)
        send_resp(conn, 200, GenerateWW.initial_response(config))
      {:error, error} ->
        send_resp(conn, 200, error)
    end
  end

  match _ do
    render_json conn, %{error: "No Route"}, 404
  end

  def merge_body_params(conn, _opts) do
    case Plug.Conn.read_body(conn) do
      {:ok, raw_query, conn} ->
        params = Plug.Conn.Query.decode(raw_query)
        merged = Map.merge(conn.params, params) |> IO.inspect
        %{conn | params: merged}
      _ ->
        render_json(conn, %{error: :unknown_body_type}) |> halt()
    end
  end

  def verify_slack(conn, _opts) do
    if conn.params["token"] == get_env(:slack, :verification_token) do
      conn
    else
      render_json(conn, %{error: :invalid_token}) |> halt()
    end
  end
end
