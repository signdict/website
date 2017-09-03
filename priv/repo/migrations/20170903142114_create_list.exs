defmodule SignDict.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :name, :string
      add :description, :text
      add :type, :string
      add :sort_order, :string
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:lists, [:created_by_id])

  end
end
