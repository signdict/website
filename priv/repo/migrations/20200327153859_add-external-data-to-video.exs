defmodule :"Elixir.SignDict.Repo.Migrations.Add-external-data-to-video" do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:external_id, :string)
      add(:auto_publish, :boolean, default: false)
    end

    create(index(:videos, [:external_id]))
  end
end
