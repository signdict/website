defmodule SignDict.EmbedController do
  use SignDict.Web, :controller

  alias SignDict.Services.EntryVideoLoader

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

  defp render_entry(%{conn: conn, entry: entry, video: video}, entry_link) do
    render(conn, "show.html",
           layout: {SignDict.LayoutView, "embed.html"},
           entry: entry,
           entry_path: entry_link,
           video: video,
           title: gettext("Sign for %{sign}", sign: entry.text)
         )
  end

end
