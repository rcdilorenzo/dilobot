defmodule DiloBot.WordlyWise do
  alias Porcelain.Result
  alias DiloBot.Model.WordlyWise, as: WW
  import Application, only: [get_env: 2]
  require Logger

  def path, do: "#{:code.priv_dir(:dilo_bot)}/static/wordly_wise.rb"

  def match?(text) do
    ~r/(generate.*(ww|wordly.wise|wordlywise))|((ww|wordly.wise|wordlywise).*report)|(wwr)/i
    |> Regex.match?(text)
  end

  def handle(channel) do
    mapping = get_env(:dilo_bot, :ww_channel_mapping)
    case Map.get(mapping, channel |> String.to_atom) do
      nil ->
        {:error, "Wordly wise generation only available in #{available_channels}."}
      ww_username ->
        generate(ww_username)
    end
  end

  defp available_channels do
    keys = get_env(:dilo_bot, :ww_channel_mapping) |> Map.keys
    channels = Slack.Web.Channels.list["channels"]
    |> Enum.filter_map(&(String.to_atom(&1["id"]) in keys), fn
      (%{"id" => id, "name" => name}) ->
        "<##{id}|#{name}>"
    end)
    |> Enum.join(", ")
  end

  def message(%WW{name: name, grade: grade, level: level,
                  lesson: lesson, columns: columns, rows: rows}) do
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
        text: "Report for #{name} (Grade #{grade}, Lesson #{lesson}, Level #{level})",
        fields: fields
      }] |> Poison.encode!
    }
  end

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

  defp generate(user) do
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
