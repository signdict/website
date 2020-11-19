defmodule SignDictWeb.Resolvers.EntryResolver do
  alias SignDict.Repo
  alias SignDict.Entry
  alias SignDict.Services.Url
  import Ecto.Query, only: [preload: 2]

  def entries(_parent, args, %{context: %{domain: domain}}) do
    page = Map.get(args, :page, 1)
    size = Enum.min([100, Map.get(args, :per_page, 50)])

    entries =
      Entry
      |> Entry.for_domain(domain)
      |> Entry.paginate(page, size)
      |> preload([:language, current_video: :user, videos: :user])
      |> Repo.all()
      |> Enum.map(fn e ->
        e |> Url.for_entry()
      end)

    {:ok, entries}
  end

  def show_entry(_parent, args, %{context: %{domain: domain}}) do
    entry =
      Entry
      |> Entry.for_domain(domain)
      |> Repo.get(args[:id])
      |> Repo.preload([:language, current_video: :user, videos: :user])
      |> Url.for_entry()

    case entry do
      nil -> {:error, message: "Not found"}
      entry -> {:ok, entry}
    end
  end

  def search_entries(_parent, args, %{context: %{domain: domain}}) do
    language =
      args
      |> Map.get(:language, Gettext.get_locale(SignDictWeb.Gettext))

    entries =
      language
      |> Entry.search_query(domain, args[:word])
      |> Entry.with_language()
      |> Entry.with_videos_and_users()
      |> Entry.with_current_video()
      |> Entry.for_letter(args[:letter])
      |> Repo.all()
      |> Enum.map(fn e ->
        e |> Url.for_entry()
      end)

    case entries do
      [] -> {:ok, []}
      entries -> {:ok, entries}
    end
  end
end
