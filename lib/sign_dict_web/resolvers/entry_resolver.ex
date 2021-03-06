defmodule SignDictWeb.Resolvers.EntryResolver do
  alias SignDict.Repo
  alias SignDict.Entry
  alias SignDict.Video
  alias SignDict.Services.Url
  import Ecto.Query, only: [from: 2, preload: 2]

  def entries(_parent, args, %{context: %{domain: domain}}) do
    page = Map.get(args, :page, 1)

    if page < 1 do
      {:error, "Page must be >= 1"}
    else
      size = Enum.min([100, Map.get(args, :per_page, 50)])

      entries =
        Entry
        |> Entry.for_domain(domain)
        |> Entry.paginate(page, size)
        |> preload([:language, current_video: :user])
        |> Entry.with_videos_and_users()
        |> Repo.all()
        |> Enum.map(fn e ->
          Url.for_entry(e, domain)
        end)

      {:ok, entries}
    end
  end

  def show_entry(_parent, args, %{context: %{domain: domain}}) do
    if args[:id] == nil do
      {:error, "parameter 'id' missing"}
    else
      video_query = from video in Video, order_by: video.id, preload: [:user]

      entry =
        Entry
        |> Entry.for_domain(domain)
        |> Repo.get(args[:id])
        |> Repo.preload([:language, current_video: :user, videos: video_query])
        |> Url.for_entry(domain)

      case entry do
        nil -> {:error, "Not found"}
        entry -> {:ok, entry}
      end
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
        Url.for_entry(e, domain)
      end)

    case entries do
      [] -> {:ok, []}
      entries -> {:ok, entries}
    end
  end
end
