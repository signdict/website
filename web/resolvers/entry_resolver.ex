defmodule SignDict.Resolvers.EntryResolver do
  alias SignDict.Repo
  alias SignDict.Entry

  def show_entry(_parent, args, _resolution) do
    entry =
      Entry
      |> Repo.get(args[:id])
      |> Repo.preload([:language, current_video: :user, videos: :user])
      |> Entry.set_url()

    case entry do
      nil -> {:error, message: "Not found"}
      entry -> {:ok, entry}
    end
  end

  def search_entries(_parent, args, _resolution) do
    entries =
      args[:language]
      |> Entry.search_query(args[:word])
      |> Entry.with_language()
      |> Entry.with_videos_and_users()
      |> Entry.with_current_video()
      |> Entry.for_letter(args[:letter])
      |> Repo.all()
      |> Enum.map(fn e -> e |> Entry.set_url() end)

    case entries do
      [] -> {:ok, []}
      entries -> {:ok, entries}
    end
  end
end
