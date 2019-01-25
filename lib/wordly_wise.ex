defmodule DiloBot.WordlyWise do
  alias Porcelain.Result
  alias WordlyWiseActivity, as: WWA
  import Application, only: [get_env: 2]
  require Logger

  def path, do: "#{:code.priv_dir(:dilo_bot)}/static/wordly_wise.rb"

  def print_env do
    get_env(:dilo_bot, :ww_keys)
    |> Enum.map(fn (key) ->
      name = key |> Atom.to_string |> String.upcase
      value = case get_env(:dilo_bot, key) do
                map when is_map(map) ->
                  Poison.encode!(map)
                any ->
                  any
              end
      "export #{name}=#{inspect value}"
    end)
    |> Enum.join("\n")
  end

  def generate(user) do
    env = get_env(:dilo_bot, :ww_keys) |> Enum.reduce([], fn (key, list) ->
      list ++ [{
        Atom.to_string(key) |> String.upcase,
        get_env(:dilo_bot, key)
      }]
    end)
    case Porcelain.exec(path, [user], env: env) do
      %Result{status: 1, err: err} ->
        Logger.error "Fetch Error: #{err}"
        {:error, "Could not fetch wordly wise data for #{inspect user}."}
      %Result{status: 0, out: output} ->
        parse_result(output)
    end
  end

  defp parse_result(output) do
    case Poison.decode(output) do
      {:ok, results} ->
        {:ok, save_results(results)}
      {:error, error} ->
        Logger.error(output)
        {:error, "Could not parse wordly wise data."}
    end
  end

  defp save_results(results) do
    for result <- results do
      WordlyWiseActivity.create_or_update_with!(result)
    end
  end
end
