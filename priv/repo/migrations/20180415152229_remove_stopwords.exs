defmodule SignDict.Repo.Migrations.RemoveStopwords do
  use Ecto.Migration

  def change do
    drop_trigger_function()
    add_dictionaries()
    add_trigger_function()
    activate_trigger()
    trigger_existing_records()
  end

  defp add_dictionaries do
    execute("""
    CREATE TEXT SEARCH DICTIONARY english_stem_nostop (
        Template = snowball
        , Language = english
    );
    """)

    execute("""
      CREATE TEXT SEARCH DICTIONARY german_stem_nostop (
          Template = snowball
          , Language = german
      );
    """)

    execute("""
      CREATE TEXT SEARCH CONFIGURATION public.english_nostop ( COPY = pg_catalog.english );
    """)

    execute("""
      ALTER TEXT SEARCH CONFIGURATION public.english_nostop ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, hword, hword_part, word WITH english_stem_nostop;
    """)

    execute("""
      CREATE TEXT SEARCH CONFIGURATION public.german_nostop ( COPY = pg_catalog.german );
    """)

    execute("""
      ALTER TEXT SEARCH CONFIGURATION public.german_nostop ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, hword, hword_part, word WITH german_stem_nostop;
    """)
  end

  defp add_trigger_function do
    execute("""
      CREATE OR REPLACE FUNCTION entry_fulltext_search_update() RETURNS trigger AS $$
          declare
            language languages%ROWTYPE;
            locale   varchar;
          begin
            SELECT * INTO language from languages WHERE id = new.language_id;

            if language.default_locale = 'de' then
              locale = 'german_nostop';
            elsif language.default_locale = 'en' then
              locale = 'english_nostop';
            else
              locale = 'simple';
            end if;

            new.fulltext_search := to_tsvector(locale::regconfig, unaccent(new.text));
            return new;
          end
      $$ LANGUAGE plpgsql;
    """)
  end

  defp drop_trigger_function do
    execute("DROP TRIGGER entry_fulltext_search_trigger on entries")
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
