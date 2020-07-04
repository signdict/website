defmodule :"Elixir.SignDict.Repo.Migrations.Added-signwriting-to-video" do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:sign_writing, :string)
    end
  end
end
