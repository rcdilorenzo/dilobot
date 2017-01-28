defmodule DiloBot.Model.WordlyWise do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "wordly_wise" do
    field :name, :string
    field :grade, :integer
    field :lesson, :integer
    field :level, :float
    field :columns, {:array, :string}
    field :rows, {:array, {:array, :string}}

    timestamps
  end

  def names do
    names = from(ww in __MODULE__, group_by: ww.name, select: ww.name)
    |> DiloBot.Repo.all
    ["All"] ++ names
  end

  def results(nil, sort_func), do: results("All", sort_func)

  def results("All", sort_func) do
    from(ww in __MODULE__, order_by: [desc: :grade, desc: :lesson])
    |> DiloBot.Repo.all
    |> Enum.flat_map(&WordlyWiseLine.lines/1)
    |> sort_func.()
    |> Enum.group_by(&(&1.name))
  end

  def results(name, sort_func) when is_binary(name) do
    from(ww in __MODULE__, where: ww.name == ^name, order_by: [desc: :grade, desc: :lesson])
    |> DiloBot.Repo.all
    |> Enum.flat_map(&WordlyWiseLine.lines/1)
    |> sort_func.()
    |> Enum.group_by(&(&1.name))
  end

  def results(_name, _sort_func), do: %{}

  def created(result) do
    to_string(result.inserted_at) |> String.split(" ") |> List.first
  end

  def create_or_update_with!(params) do
    identification = [
      name: params["name"],
      grade: params["grade"],
      lesson: params["lesson"],
      level: params["level"]
    ]
    case DiloBot.Repo.get_by(__MODULE__, identification) do
      nil ->
        changeset(%__MODULE__{}, params)
        |> DiloBot.Repo.insert!
      model ->
        changeset(model, params)
        |> DiloBot.Repo.update!
    end
  end

  def changeset(model, params \\ %{}) do
    cast(model, params, [:name, :grade, :level, :lesson, :columns, :rows])
    |> validate_required([:name, :grade, :level, :lesson, :columns, :rows])
  end
end
