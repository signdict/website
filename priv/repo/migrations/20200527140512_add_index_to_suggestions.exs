defmodule SignDict.Repo.Migrations.AddIndexToSuggestions do
  use Ecto.Migration

  def change do
    create(index(:suggestions, [:user_id]))
    execute("CREATE INDEX trgm_suggestions_word ON suggestions USING GIN(word gin_trgm_ops);")
  end
end
