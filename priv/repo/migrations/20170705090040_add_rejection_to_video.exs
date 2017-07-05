defmodule SignDict.Repo.Migrations.AddRejectionToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :rejection_reason, :text
    end
  end
end
