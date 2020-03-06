defmodule SignDict.Repo.Migrations.UpdateCurrentVideoId do
  use Ecto.Migration

  def up do
    drop(constraint(:entries, "entries_current_video_id_fkey"))

    alter table(:entries) do
      modify(:current_video_id, references(:videos, on_delete: :nilify_all))
    end
  end

  def down do
    drop(constraint(:entries, "entries_current_video_id_fkey"))

    alter table(:entries) do
      modify(:current_video_id, references(:person, on_delete: :nothing))
    end
  end
end
