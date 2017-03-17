defmodule SignDict.Repo.Migrations.AddEntryToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :entry_id, references(:entries, on_delete: :nothing)
    end

    create index(:videos, [:entry_id])
  end
end
