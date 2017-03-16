defmodule SignDict.Repo.Migrations.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :iso6393, :string
      add :long_name, :string
      add :short_name, :string
      add :default_locale, :string

      timestamps()
    end

    create unique_index(:languages, [:iso6393])
  end
end
