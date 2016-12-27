defmodule DiloBot.Repo.Migrations.CreateWordlyWise do
  use Ecto.Migration

  def change do
    create table(:wordly_wise) do
      add :name, :string
      add :grade, :integer
      add :lesson, :integer
      add :columns, {:array, :string}
      add :rows, {:array, {:array, :string}}

      timestamps
    end
  end
end
