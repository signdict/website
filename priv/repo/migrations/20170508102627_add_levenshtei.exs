defmodule SignDict.Repo.Migrations.AddLevenshtei do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION fuzzystrmatch;")
  end
end
