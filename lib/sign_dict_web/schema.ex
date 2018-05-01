defmodule SignDictWeb.Schema do

  use Absinthe.Schema
  import_types SignDictWeb.Schema.Types
  alias SignDictWeb.Resolvers.EntryResolver

  query do
    @desc "Get an entry by ID"
    field :entry, :entry do
      arg :id, :id
      resolve &EntryResolver.show_entry/3
    end

    @desc "Search for entry"
    field :search, list_of(:entry) do
      arg :word, :string, description: "Word to search by"
      arg :letter, :string, description: "Letter to search by"
      resolve &EntryResolver.search_entries/3
    end
  end
end
