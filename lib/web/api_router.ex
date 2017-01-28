defmodule DiloBot.ApiRouter do
  use Plug.Router
  use DiloBot.Web.Render

  alias DiloBot.Model.WordlyWise

  plug BasicAuth, use_config: {:dilo_bot, :auth}
  plug :fetch_query_params
  plug :match
  plug :dispatch

  get "/wordly_wise/names" do
    render_json conn, WordlyWise.names
  end

  get "/wordly_wise" do
    results = WordlyWise.results(conn.params["name"], &sort_lines(&1, conn.params))
    render_json conn, results
  end

  match _ do
    render_json conn, %{error: "No Route"}, 404
  end

  def sort_lines(lines, %{"sort" => "activity"}) do
    Enum.sort_by(lines, &(&1.activity))
  end
  def sort_lines(lines, _params), do: lines
end
