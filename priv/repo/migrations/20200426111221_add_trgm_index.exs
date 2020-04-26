defmodule SignDict.Repo.Migrations.AddTrgmIndex do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
    execute("CREATE INDEX trgm_entry_text ON entries USING GIN(text gin_trgm_ops);")
  end
end
