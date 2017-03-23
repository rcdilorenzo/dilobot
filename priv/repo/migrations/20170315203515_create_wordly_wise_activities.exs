defmodule DiloBot.Repo.Migrations.CreateWordlyWiseActivities do
  use Ecto.Migration

  def change do
    create table(:wordly_wise_activities) do
      add :name, :string, null: false
      add :grade, :integer, null: false
      add :lesson, :integer, null: false
      add :level, :float, null: false

      add :date, :date
      add :activity, :string, null: false
      add :seconds, :integer, null: false
      add :score, :integer, null: false

      timestamps()
    end
  end
end
