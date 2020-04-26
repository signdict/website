defmodule SignDict.Repo.Migrations.AddFulltextIndexToEntries do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :fulltext_search, :tsvector
    end
    execute("CREATE INDEX entries_fulltext_search ON entries USING gin(fulltext_search);")
    execute("CREATE EXTENSION IF NOT EXISTS unaccent;")

    add_trigger_function()
    activate_trigger()
    trigger_existing_records()
  end

  defp add_trigger_function do
    execute("""
      CREATE FUNCTION entry_fulltext_search_update() RETURNS trigger AS $$
          declare
            language languages%ROWTYPE;
            locale   varchar;
          begin
            SELECT * INTO language from languages WHERE id = new.language_id;

            if language.default_locale = 'de' then
              locale = 'german';
            elsif language.default_locale = 'en' then
              locale = 'english';
            else
              locale = 'simple';
            end if;

            new.fulltext_search := to_tsvector(locale::regconfig, unaccent(new.text));
            return new;
          end
      $$ LANGUAGE plpgsql;
    """)
  end

  defp activate_trigger do
    execute("""
     CREATE TRIGGER entry_fulltext_search_trigger BEFORE INSERT OR UPDATE
         ON entries FOR EACH ROW EXECUTE PROCEDURE entry_fulltext_search_update();
    """)
  end

  defp trigger_existing_records do
    execute("UPDATE entries set text=text;")
  end

end
