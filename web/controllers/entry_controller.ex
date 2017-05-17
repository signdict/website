defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Services.EntryVideoLoader

  def show(conn, %{"id" => id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id)
    |> render_entry
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    conn
    |> EntryVideoLoader.load_videos_for_entry(id: id, video_id: video_id)
    |> render_entry
  end

  defp render_entry(%{conn: conn, videos: videos}) when length(videos) == 0 do
    redirect_no_videos(conn)
  end
  defp render_entry(%{conn: conn, entry: entry, videos: videos, video: video, voted: voted}) do
    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           voted_video: voted,
           searchbar: true,
           ogtags: SignDict.Services.OpenGraph.to_metadata(entry, video),
           title: gettext("Sign for %{sign}", sign: entry.text)
         )
  end
  defp render_entry(%{conn: conn}) do
    redirect_no_videos(conn)
  end

  defp redirect_no_videos(conn) do
    conn
    |> put_flash(:info, gettext("Sorry, I could not find an entry for this."))
    |> redirect(to: "/")
  end

end
