defmodule SignDict.Repo.Migrations.AddSuggestions do
  use Ecto.Migration

  def change do
    create table(:suggestions) do
      add(:user_id, references(:users, on_delete: :nilify_all))
      add(:word, :string)
      add(:description, :text)
      timestamps()
    end
  end
end
