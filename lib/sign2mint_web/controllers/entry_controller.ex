defmodule Sign2MintWeb.EntryController do
  @moduledoc """
  """
  use Sign2MintWeb, :controller

  alias SignDict.Entry
  alias SignDict.Domain
  alias SignDict.Services.EntryVideoLoader
  alias SignDict.Services.OpenGraph
  alias SignDictWeb.Router.Helpers

  def index(conn, params) do
    letter = params["letter"] || "A"

    entries =
      Entry.active_entries(conn.host)
      |> Entry.with_videos()
      |> Entry.with_current_video()
      |> Entry.for_letter(letter)
      |> SignDict.Repo.paginate(Map.merge(params, %{page_size: 20}))

    render(conn, "index.html",
      entries: entries,
      searchbar: true,
      letter: letter,
      title: gettext("All entries")
    )
  end

  def show(conn, %{"id" => id}) do
    if id =~ ~r/^\d+(-.*)?\z/ do
      conn
      |> EntryVideoLoader.load_videos_for_entry(id: id, filter_videos: true)
      |> render_entry
    else
      redirect_to_search(conn, conn.params["id"])
    end
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id, video_id: video_id, filter_videos: true)
    |> render_entry
  end

  defp render_entry(%{conn: conn, entry: entry, video: video})
       when is_nil(video) and not is_nil(entry) do
    conn
    |> redirect(to: entry_path(conn, :show, entry))
  end

  defp render_entry(%{
         conn: conn,
         entry: entry,
         videos: videos,
         video: video,
         voted: voted
       }) do
    entry = SignDict.Repo.preload(entry, :sign_writings)

    SignDict.Analytics.increase_video_count(
      Domain.for(conn.host),
      conn |> get_req_header("user-agent") |> List.first(),
      conn.assigns.current_user,
      video
    )

    conn
    |> put_router_url(SignDict.Services.Url.base_url_from_conn(conn))
    |> render("show.html",
      layout: get_layout_for(conn.host, "empty.html"),
      entry: entry,
      video: video,
      videos: videos,
      share_url: Helpers.url(conn) <> conn.request_path,
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
    query =
      Regex.named_captures(~r/^(\d*-)?(?<query>.*)$/, id)["query"]
      |> String.replace("-", " ")

    conn
    |> redirect(to: search_path(conn, :index, q: query))
  end
end
