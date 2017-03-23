defmodule WordlyWiseActivity do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias DiloBot.Model.WordlyWise, as: WW

  @test_activities ~w(Pre-Test Post-Test)
  @properties [:name, :grade, :lesson, :level, :date, :activity, :seconds, :score]

  schema "wordly_wise_activities" do
    field :name,   :string
    field :grade,  :integer
    field :lesson, :integer
    field :level,  :float

    field :date,     Ecto.Date
    field :activity, :string
    field :seconds,  :integer
    field :score,    :integer

    timestamps()
  end

  def identification(%{lesson: lesson, level: level}) do
    "#{level}.#{lesson}"
  end

  def score(activity) do
    "#{activity.score}%"
  end

  def duration(activity) do
    "#{div(activity.seconds, 60)}:#{rem(activity.seconds, 60)}"
  end

  def compact_date(%{date: date}) do
    "#{date.month |> pad}-#{date.day |> pad}-#{rem(date.year, 2000) |> pad}"
  end

  defp pad(value) when value < 10, do: "0#{value}"
  defp pad(value), do: "#{value}"

  def names do
    names = from(ww in __MODULE__, group_by: ww.name, select: ww.name)
    |> DiloBot.Repo.all
    ["All"] ++ names
  end

  def results(nil), do: results("All")

  def results("All") do
    from(ww in __MODULE__, order_by: [desc: :grade, desc: :lesson])
    |> DiloBot.Repo.all
    |> Enum.map(&encode/1)
    |> Enum.group_by(&(&1.name))
  end

  def results(name) when is_binary(name) do
    from(ww in __MODULE__, where: ww.name == ^name, order_by: [desc: :grade, desc: :lesson])
    |> DiloBot.Repo.all
    |> Enum.map(&encode/1)
    |> Enum.group_by(&(&1.name))
  end

  def results(_name), do: %{}

  def create_or_update_with!(params) do
    identification = [
      name: params["name"],
      grade: params["grade"],
      lesson: params["lesson"],
      level: params["level"],
      activity: params["activity"]
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
    cast(model, params, @properties)
    |> validate_required(@properties -- [:date])
    |> set_date
  end

  def set_date(changeset) do
    cond do
      not is_nil(get_field(changeset, :date)) and not get_field(changeset, :activity) in @test_activities ->
        delete_change(changeset, :date)
      is_nil(get_field(changeset, :date)) ->
        put_change(changeset, :date, today())
      true ->
        changeset
    end
  end

  def encode(wordly_wise_activity) do
    Map.take(wordly_wise_activity, [:name, :grade, :lesson, :level, :date, :activity, :seconds, :score])
  end

  def today() do
    {{year, month, day}, _time} = :erlang.localtime()
    %Ecto.Date{year: year, month: month, day: day}
  end

  def test_activity?(%{activity: activity_name}) when activity_name in @test_activities, do: true
  def test_activity?(_activity), do: false
end
