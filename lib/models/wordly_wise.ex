defmodule DiloBot.Model.WordlyWise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wordly_wise" do
    field :name, :string
    field :grade, :integer
    field :lesson, :integer
    field :columns, {:array, :string}
    field :rows, {:array, {:array, :string}}

    timestamps
  end

  def create_or_update_with!(params) do
    identification = [
      name: params["name"],
      grade: params["grade"],
      lesson: params["lesson"]
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
    cast(model, params, [:name, :grade, :lesson, :columns, :rows])
    |> validate_required([:name, :grade, :lesson, :columns, :rows])
  end
end
