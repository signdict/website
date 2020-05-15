defmodule SignDict.Repo.Migrations.AddAnalyticsTables do
  use Ecto.Migration

  def change do
    create table(:video_analytics) do
      add(:domain_id, references(:domains, on_delete: :delete_all))
      add(:entry_id, references(:entries, on_delete: :delete_all))
      add(:video_id, references(:videos, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :nilify_all))
      timestamps()
    end

    create(index(:video_analytics, [:domain_id]))
    create(index(:video_analytics, [:entry_id]))
    create(index(:video_analytics, [:video_id]))
    create(index(:video_analytics, [:user_id]))

    alter table(:entries) do
      add(:view_count, :bigint, default: 0)
    end

    alter table(:videos) do
      add(:view_count, :bigint, default: 0)
      remove(:plays)
    end
  end
end
