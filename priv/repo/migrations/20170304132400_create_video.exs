defmodule SignDict.Repo.Migrations.CreateVideo do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :state, :string
      add :copyright, :string
      add :license, :string
      add :original_href, :string
      add :type, :string

      timestamps()
    end

  end
end
