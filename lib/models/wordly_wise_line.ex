defmodule WordlyWiseLine do
  defstruct name: nil, grade: nil, lesson: nil, level: nil, attempt: 1,
    activity: nil, percent_correct: nil, created: nil

  alias DiloBot.Model.WordlyWise

  def lines(%WordlyWise{} = result) do
    for row <- result.rows, valid_row?(row)  do
      {:ok, activity, attempt} = List.first(row) |> split_attempt
      %__MODULE__{
        name: result.name,
        grade: result.grade,
        lesson: result.lesson,
        level: result.level,
        created: WordlyWise.created(result),
        activity: activity,
        attempt: attempt,
        percent_correct: List.last(row) |> percent_to_integer
      }
    end
  end

  def valid_row?(row) do
    List.last(row) != "---"
  end

  def split_attempt(name) do
    case Regex.scan(~r/\s\((\d+)\w+\s\w+\)/, name) do
      [] ->
        {:ok, name, 1}
      [[match, attempt]] ->
        {:ok, String.replace(name, match, ""), String.to_integer(attempt)}
    end
  end

  def id(line), do: "Lesson #{line.lesson} / Level #{line.level}"

  @doc "export activities for a single user for R"
  def export_activities(lines) do
    ids = Enum.group_by(lines, &id/1)
    |> Map.keys
    |> Enum.sort
    data = Enum.group_by(lines, &(&1.activity))
    |> Enum.map(fn ({activity, lines}) ->
      [activity | Enum.map(lines, &(&1.percent_correct))] |> Enum.join(",")
    end)
    |> Enum.join("\n")
    Enum.join(["Activity" | ids], ",") <> "\n" <> data
  end

  def percent_to_integer(string) do
    String.replace(string, "%", "")
    |> String.to_integer
  end
end
