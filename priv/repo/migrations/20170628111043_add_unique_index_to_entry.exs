defmodule SignDict.Repo.Migrations.AddUniqueIndexToEntry do
  use Ecto.Migration

  def change do
    create unique_index(:entries, [:text, :description])
  end
end
