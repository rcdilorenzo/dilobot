defmodule DiloBot.WordlyWise do
  alias Porcelain.Result
  alias DiloBot.Model.WordlyWise, as: WW
  import Application, only: [get_env: 2]
  require Logger

  def path, do: "#{:code.priv_dir(:dilo_bot)}/static/wordly_wise.rb"

  def handle(username) do
    if username =~ ~r/[a-zA-Z]/ do
      generate(username)
    else
      {:error, "Unknown user #{username}"}
    end
  end

  def message(%WW{name: name, grade: grade, lesson: lesson, columns: columns, rows: rows}) do
    half = Float.ceil(length(columns) / 2) |> trunc
    {first_set, second_set} = Enum.split(columns, half)
    fields = for column_set <- [first_set, second_set] do
      Enum.reduce(0..(length(column_set) - 1), %{short: true, title: "", value: ""}, fn
        0, map ->
          column = List.first(column_set)
          row_index = Enum.find_index(columns, &(&1 == column))
          Map.merge(map, %{
            title: column,
            value: Enum.map(rows, &Enum.at(&1, row_index)) |> Enum.join("\n")
          })
        i, %{title: title, value: value} = map ->
          column = Enum.at(column_set, i)
          row_index = Enum.find_index(columns, &(&1 == column))
          Map.merge(map, %{
            title: title <> " / " <> column,
            value: String.split(value, "\n")
            |> Enum.zip(Enum.map(rows, &Enum.at(&1, row_index)))
            |> Enum.map(fn ({first, second}) -> first <> " / " <> second end)
            |> Enum.join("\n")
          })
      end)
    end
    %{
      as_user: true,
      attachments: [%{
        type: "message",
        color: "#F35A00",
        text: "Report for #{name} (Grade #{grade}, Lesson #{lesson})",
        fields: fields
      }] |> Poison.encode!
    }
  end

  defp generate(username) do
    env = get_env(:dilo_bot, :ww_keys) |> Enum.reduce([], fn (key, list) ->
      list ++ [{
        Atom.to_string(key) |> String.upcase,
        get_env(:dilo_bot, key)
      }]
    end)
    case Porcelain.exec(path, [username], env: env) do
      %Result{status: 1, err: err} ->
        Logger.error "Fetch Error: #{err}"
        {:error, "Could not fetch wordly wise data for #{username}."}
      %Result{status: 0, out: output} ->
        parse_result(output)
    end
  end

  defp parse_result(output) do
    case Poison.decode(output) do
      {:ok, results} ->
        {:ok, save_results(results)}
      {:error, _error} ->
        {:error, "Could not parse wordly wise data."}
    end
  end

  defp save_results(results) do
    for result <- results do
      DiloBot.Model.WordlyWise.create_or_update_with!(result)
    end
  end
end
