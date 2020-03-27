defmodule SignDict.Repo.Migrations.AddImporterConfig do
  use Ecto.Migration

  def change do
    create table(:importer_configs) do
      add(:name, :string)
      add(:configuration, :map)
      timestamps()
    end

    create(index(:importer_configs, [:name]))
  end
end
