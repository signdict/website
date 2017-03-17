defmodule SignDict.Repo.Migrations.AddUserToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:videos, [:user_id])
  end
end
