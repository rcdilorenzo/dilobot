defmodule DiloBot.Repo.Migrations.DropOldWordlyWiseTable do
  use Ecto.Migration

  def up do
    drop table(:wordly_wise)
  end
end
