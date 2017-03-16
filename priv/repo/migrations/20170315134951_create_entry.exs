defmodule SignDict.Repo.Migrations.CreateEntry do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :text, :string
      add :description, :text
      add :language_id, references(:languages, on_delete: :nothing)
      add :type, :string

      timestamps()
    end
    create index(:entries, [:language_id])

  end
end
