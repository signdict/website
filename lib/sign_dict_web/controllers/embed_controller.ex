defmodule SignDictWeb.EmbedController do
  use SignDictWeb, :controller

  alias SignDict.Services.EntryVideoLoader
  alias SignDict.Services.OpenGraph

  def show(conn, %{"id" => id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id)
    |> render_entry(entry_path(conn, :show, id))
  end

  def show(conn, %{"embed_id" => id, "video_id" => video_id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id, video_id: video_id)
    |> render_entry(entry_video_path(conn, :show, id, video_id))
  end

  defp render_entry(%{conn: conn, videos: videos}, _entry_link) when length(videos) == 0 do
    render(conn, "show_no_video.html",
      layout: {SignDictWeb.LayoutView, "embed.html"},
      title: gettext("Sorry, no sign found")
    )
  end

  defp render_entry(%{conn: conn, entry: entry, video: video}, _entry_link)
       when is_nil(video) and not is_nil(entry) do
    conn
    |> redirect(to: embed_path(conn, :show, entry))
  end

  defp render_entry(%{conn: conn, entry: entry, video: video}, entry_link) do
    render(conn, "show.html",
      autoplay: conn.params["autoplay"],
      layout: {SignDictWeb.LayoutView, "embed.html"},
      entry: entry,
      entry_path: entry_link,
      video: video,
      ogtags: OpenGraph.to_metadata(entry, video),
      title: gettext("Sign for %{sign}", sign: entry.text)
    )
  end

  defp render_entry(%{conn: conn}, _entry_link) do
    render(conn, "show_no_video.html",
      layout: {SignDictWeb.LayoutView, "embed.html"},
      title: gettext("Sorry, no sign found")
    )
  end
end
