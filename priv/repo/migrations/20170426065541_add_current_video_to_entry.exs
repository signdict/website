defmodule SignDict.Repo.Migrations.AddCurrentVideoToEntry do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :current_video_id, references(:videos, on_delete: :nothing)
    end

    create index(:entries, [:current_video_id])
  end
end
