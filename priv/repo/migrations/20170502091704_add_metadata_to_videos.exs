defmodule SignDict.Repo.Migrations.AddMetadataToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :metadata, :map
    end
  end
end
