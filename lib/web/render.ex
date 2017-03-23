defmodule DiloBot.Web.Render do
  import Plug.Conn
  defmacro __using__(_opts) do
    quote do
      import DiloBot.Web.Render
      alias DiloBot.Repo
    end
  end

  def static_dir, do: "#{:code.priv_dir(:dilo_bot)}/static"
  def templates_dir, do: static_dir <> "/templates"

  def render_json(conn, json, status \\ 200) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(json))
  end

  def render_page(conn, name, assigns \\ []) do
    bindings = [
      template: "#{templates_dir}/#{name}.html.eex",
      assigns: assigns ++ [render_js: &render_js/1]
    ]
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, EEx.eval_file("#{templates_dir}/layout.html.eex", bindings))
  end

  def render_js(filename) do
    output = File.read!(static_dir <> "/js/#{filename}.js")
    "document.addEventListener(\"DOMContentLoaded\", function(event) {
      #{output}
    });"
  end
end
