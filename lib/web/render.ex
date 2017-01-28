defmodule DiloBot.Web.Render do
  import Plug.Conn
  @vendor ~w(vue.js axios.min.js underscore-min.js query.min.js)

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
      vendor_js: vendor_js,
      assigns: assigns ++ [render_js: &render_js/1]
    ]
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, EEx.eval_file("#{templates_dir}/layout.html.eex", bindings))
  end

  def render_js(filename) do
    File.read!(static_dir <> "/js/#{filename}.js")
  end

  defp vendor_js do
    Enum.map(@vendor, &File.read!(static_dir <> "/js/" <> &1))
    |> Enum.join("\n")
  end
end
