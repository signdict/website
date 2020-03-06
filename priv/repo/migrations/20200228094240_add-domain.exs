defmodule :"Elixir.SignDict.Repo.Migrations.Add-domain" do
  use Ecto.Migration

  def change do
    create table(:domains) do
      add(:domain, :string)
      timestamps()
    end

    create(index(:domains, [:domain]))

    create table(:domains_entries) do
      add(:domain_id, references(:domains, on_delete: :delete_all))
      add(:entry_id, references(:entries, on_delete: :delete_all))
    end

    create(index(:domains_entries, [:domain_id]))
    create(index(:domains_entries, [:entry_id]))

    create(
      unique_index(:domains_entries, [:entry_id, :domain_id],
        name: :domain_id_entry_id_unique_index
      )
    )
  end
end
