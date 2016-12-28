defmodule DiloBot.Repo.Migrations.AddLevelToWordlyWise do
  use Ecto.Migration

  def change do
    alter table(:wordly_wise) do
      add :level, :float
    end
  end
end
