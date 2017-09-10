defmodule SignDict.Repo.Migrations.CreateListEntry do
  use Ecto.Migration

  def change do
    create table(:list_entries) do
      add :sort_order, :integer
      add :list_id, references(:lists, on_delete: :nothing)
      add :entry_id, references(:entries, on_delete: :nothing)

      timestamps()
    end
    create index(:list_entries, [:list_id])
  end
end
