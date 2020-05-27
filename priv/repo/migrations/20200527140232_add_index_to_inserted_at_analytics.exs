defmodule SignDict.Repo.Migrations.AddIndexToInsertedAtAnalytics do
  use Ecto.Migration

  def change do
    create(index(:video_analytics, [:inserted_at]))
  end
end
