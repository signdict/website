defmodule SignDictWeb.Schema do
  use Absinthe.Schema
  import_types(SignDictWeb.Schema.Types)
  alias SignDictWeb.Resolvers.EntryResolver

  query do
    @desc "List all entries"
    field :index, list_of(:entry) do
      arg(:page, :integer, description: "Page number (default is 1)")
      arg(:per_page, :integer, description: "Entries per page (default is 50).")
      resolve(&EntryResolver.entries/3)
    end

    @desc "Get an entry by ID"
    field :entry, :entry do
      arg(:id, :id)
      resolve(&EntryResolver.show_entry/3)
    end

    @desc "Search for entry"
    field :search, list_of(:entry) do
      arg(:word, :string, description: "Word to search by")
      arg(:letter, :string, description: "Letter to search by")
      resolve(&EntryResolver.search_entries/3)
    end
  end
end
