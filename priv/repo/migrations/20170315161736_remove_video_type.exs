defmodule SignDict.Repo.Migrations.RemoveVideoType do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      remove :type
    end
  end
end
