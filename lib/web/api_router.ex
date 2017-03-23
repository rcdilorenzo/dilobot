defmodule DiloBot.ApiRouter do
  use Plug.Router
  use Plug.Builder
  use DiloBot.Web.Render

  plug BasicAuth, use_config: {:dilo_bot, :auth}
  plug :fetch_query_params
  plug :match
  plug :dispatch

  get "/wordly_wise/names" do
    render_json conn, WordlyWiseActivity.names
  end

  get "/wordly_wise" do
    results = WordlyWiseActivity.results(conn.params["name"])
    render_json conn, results
  end

  match _ do
    render_json conn, %{error: "No Route"}, 404
  end
end
