defmodule SignDict.Repo.Migrations.AddUniqueToListEvents do
  use Ecto.Migration

  def change do
    create unique_index(:list_entries, [:list_id, :entry_id])
  end
end
