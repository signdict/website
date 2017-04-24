defmodule SignDict.Repo.Migrations.AddPathsToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :video_url, :string
      add :thumbnail_url, :string
      add :duration_seconds, :integer
      add :plays, :integer
    end
  end
end
