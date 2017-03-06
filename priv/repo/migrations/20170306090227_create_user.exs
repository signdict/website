defmodule SignDict.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string

      add :name, :string
      add :biography, :text

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
