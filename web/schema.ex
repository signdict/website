defmodule SignDict.Schema do

  use Absinthe.Schema
  import_types SignDict.Schema.Types
  alias SignDict.Resolvers.EntryResolver

  query do
    @desc "Get an entry by ID"
    field :entry, :entry do
      arg :id, :id
      resolve &EntryResolver.show_entry/3
    end

    @desc "Search for entry bu word and/or letter"
    field :search, list_of(:entry) do
    # arg :language, :string, description: "Search language, default is #{Gettext.get_locale(SignDict.Gettext)}"
      arg :word, :string, description: "Word to search by"
      arg :letter, :string, description: "Letter to search by"
      resolve &EntryResolver.search_entries/3
    end
  end
end
