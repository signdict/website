defmodule SignDict.Resolvers.EntryResolver do
  alias SignDict.Repo
  alias SignDict.Entry

  def show_entry(_parent, args, _resolution) do
    case Entry |> Repo.get(args[:id]) |> Repo.preload(:language) do
      nil -> {:error, message: "Not found"}
      entry -> {:ok, entry}
    end
  end

  def search_entries(_parent, args, _resolution) do
    entries =
      args[:language]
      |> Entry.search_query(args[:word])
      |> Entry.with_language
      |> Entry.with_videos_and_users
      |> Entry.for_letter(args[:letter])
      |> Repo.all

    case entries do
      [] -> {:ok, []}
      entries -> {:ok, entries}
    end
  end
end
