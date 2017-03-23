defmodule DiloBot.WordlyWise do
  alias Porcelain.Result
  alias WordlyWiseActivity, as: WWA
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

  def message(activities = [%WWA{name: name} | _tail]) do
    filtered = Enum.filter(activities, fn (activity) ->
      activity.date == WWA.today() or not WWA.test_activity?(activity)
    end)

    first_column = Enum.reduce(filtered, "", fn
      (activity, "") ->
        "#{WWA.identification(activity)}: #{activity.activity}"
      (activity, string) ->
        "#{string}\n#{WWA.identification(activity)}: #{activity.activity}"
    end)

    second_column = Enum.reduce(filtered, "", fn
      (activity, "") ->
        "#{WWA.compact_date(activity)} / #{WWA.duration(activity)} / #{WWA.score(activity)}"
      (activity, string) ->
        "#{string}\n#{WWA.compact_date(activity)} / #{WWA.duration(activity)} / #{WWA.score(activity)}"
    end)

    %{
      as_user: true,
      attachments: [%{
        type: "message",
        color: "#F35A00",
        text: "Report for #{name}",
        fields: [
          %{short: true, title: "Activity", value: first_column},
          %{short: true, title: "Date / Time / Score", value: second_column}
        ]
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
      WordlyWiseActivity.create_or_update_with!(result)
    end
  end
end
