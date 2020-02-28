defmodule :"Elixir.SignDict.Repo.Migrations.Add-domain" do
  use Ecto.Migration

  def change do
    create table(:domains) do
      add(:domain, :string)
      timestamps()
    end

    create(index(:domains, [:domain]))

    create table(:domains_entries) do
      add(:domain_id, references(:domains))
      add(:entry_id, references(:entries))
      timestamps()
    end
  end
end
