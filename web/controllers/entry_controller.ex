defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.Services.EntryVideoLoader
  alias SignDict.Services.OpenGraph

  def index(conn, params) do
    letter = params["letter"] || "A"
    entries = Entry.active_entries
              |> Entry.with_current_video
              |> Entry.for_letter(letter)
              |> Repo.paginate(params)

    render(conn, "index.html",
           layout: {SignDict.LayoutView, "app.html"},
           entries: entries,
           searchbar: true,
           letter: letter,
           title: gettext("All entries")
         )
  end

  def show(conn, %{"id" => id}) do
    if id =~ ~r/^\d+(-.*)?\z/ do
      conn
      |> EntryVideoLoader.load_videos_for_entry(id: id)
      |> render_entry
    else
      redirect_to_search(conn, conn.params["id"])
    end
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id, video_id: video_id)
    |> render_entry
  end

  def new(conn, _params) do
    changeset = Entry.changeset(%Entry{})
    languages = Repo.all(Language)
    render(conn, "new.html", changeset: changeset, languages: languages)
  end

  def create(conn, %{"entry" => entry_params}) do
    changeset = Entry.changeset(%Entry{}, entry_params)
    entry = Entry.find_by_changeset(changeset)
    if entry do
      redirect(conn, to: recorder_path(conn, :index, entry.id))
    else
      create_entry(conn, changeset)
    end
  end

  defp create_entry(conn, changeset) do
    case Repo.insert(changeset) do
      {:ok, entry} ->
        conn
        |> redirect(to: recorder_path(conn, :index, entry.id))
      {:error, changeset} ->
        languages = Repo.all(Language)
        render(conn, "new.html", changeset: changeset, languages: languages)
    end
  end

  defp render_entry(%{conn: conn, videos: videos, entry: entry}) when length(videos) == 0 and not is_nil(entry) do
    redirect_no_videos(conn)
  end
  defp render_entry(%{conn: conn, entry: entry, video: video})
      when is_nil(video) and not is_nil(entry) do
    conn
    |> redirect(to: entry_path(conn, :show, entry))
  end
  defp render_entry(%{conn: conn, entry: entry, videos: videos,
                      video: video, voted: voted}) do
    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           share_url: SignDict.Router.Helpers.url(conn) <> conn.request_path,
           share_text: gettext("Watch this sign for \"%{sign}\" on @signdict", sign: entry.text),
           voted_video: voted,
           searchbar: true,
           ogtags: OpenGraph.to_metadata(entry, video),
           title: gettext("Sign for %{sign}", sign: entry.text)
         )
  end
  defp render_entry(%{conn: conn}) do
    if conn.params["id"] && conn.params["id"] =~ ~r/\d*-\D*/ do
      redirect_to_search(conn, conn.params["id"])
    else
      redirect_no_videos(conn)
    end
  end

  defp redirect_no_videos(conn) do
    conn
    |> put_flash(:info, gettext("Sorry, I could not find an entry for this."))
    |> redirect(to: "/")
  end

  defp redirect_to_search(conn, id) do
    query = Regex.named_captures(~r/^(\d*-)?(?<query>.*)$/, id)["query"]
            |> String.replace("-", " ")
    conn
    |> redirect(to: search_path(conn, :index, q: query))
  end

end
