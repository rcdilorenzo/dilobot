defmodule WordlyWiseLine do
  defstruct name: nil, grade: nil, lesson: nil, level: nil,
    activity: nil, percent_correct: nil, created: nil

  alias DiloBot.Model.WordlyWise

  def lines(%WordlyWise{} = result) do
    for row <- result.rows do
      %__MODULE__{
        name: result.name,
        grade: result.grade,
        lesson: result.lesson,
        level: result.level,
        created: WordlyWise.created(result),
        activity: List.first(row),
        percent_correct: List.last(row) |> percent_to_integer
      }
    end
  end

  def percent_to_integer(string) do
    String.replace(string, "%", "")
    |> String.to_integer
  end
end
