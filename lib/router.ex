defmodule DiloBot.Router do
  use Plug.Router

  alias DiloBot.{Repo, Model.WordlyWise}
  import Ecto.Query

  plug Plug.Logger
  plug BasicAuth, use_config: {:dilo_bot, :auth}
  plug :fetch_query_params
  plug :match
  plug :dispatch

  def templates_dir, do: "#{:code.priv_dir(:dilo_bot)}/static/templates"

  get "/wordly_wise/reports" do
    IO.inspect conn.params
    results = from(ww in WordlyWise, order_by: [desc: :grade, desc: :lesson])
    |> Repo.all
    |> Enum.flat_map(&WordlyWiseLine.lines/1)
    |> sort_lines(conn.params)
    |> Enum.group_by(&(&1.name))
    |> IO.inspect
    render_page conn, "wordly_wise", results: results
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def sort_lines(lines, %{"sort" => "activity"}) do
    Enum.sort_by(lines, &(&1.activity))
  end
  def sort_lines(lines, _params), do: lines

  def render_page(conn, name, assigns \\ []) do
    bindings = [template: "#{templates_dir}/#{name}.html.eex", assigns: assigns]
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, EEx.eval_file("#{templates_dir}/layout.html.eex", bindings))
  end
end
