defmodule SignDict.Repo.Migrations.AddUniqueToSortOrder do
  use Ecto.Migration

  def change do
    create unique_index(:list_entries, [:list_id, :sort_order])
  end
end
