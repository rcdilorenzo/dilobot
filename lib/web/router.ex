defmodule DiloBot.Router do
  use Plug.Router
  use DiloBot.Web.Render

  plug Plug.Logger
  plug BasicAuth, use_config: {:dilo_bot, :auth}
  plug Plug.Static,
    at: "/assets",
    from: :dilo_bot,
    only: ~w(js css)

  plug :fetch_query_params
  plug :match
  plug :dispatch

  get "/wordly_wise/reports" do
    results = WordlyWiseActivity.results(conn.params["name"])
    render_page conn, "wordly_wise",
      results: results,
      names: WordlyWiseActivity.names
  end

  forward "/api", to: DiloBot.ApiRouter

  match _ do
    send_resp(conn, 404, "oops")
  end

  def sort_lines(lines, %{"sort" => "activity"}) do
    Enum.sort_by(lines, &(&1.activity))
  end
  def sort_lines(lines, _params), do: lines
end
