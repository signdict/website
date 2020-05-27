defmodule SignDict.Repo.Migrations.AddDomainToSuggestions do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add(:domain_id, references(:domains, on_delete: :delete_all))
    end
  end
end
