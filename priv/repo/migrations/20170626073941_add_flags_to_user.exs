defmodule SignDict.Repo.Migrations.AddFlagsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :flags, {:array, :string}
    end
  end
end
