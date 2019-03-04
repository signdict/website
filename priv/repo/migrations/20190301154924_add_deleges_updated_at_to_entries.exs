defmodule SignDict.Repo.Migrations.AddDelegesUpdatedAtToEntries do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add(:deleges_updated_at, :utc_datetime)
    end
  end
end
