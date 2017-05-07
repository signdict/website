defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  def show(conn, %{"id" => id}) do
    [entry, videos] = load_videos_for_entry(id)

    if length(videos) > 0 do
      voted  = Entry.voted_video(entry, conn.assigns.current_user)
      video  = if voted && voted.id do
        voted |> Video.with_vote_count
      else
        List.first(videos)
      end

      render_entry(conn, entry, videos, video, voted)
    else
      redirect_no_videos(conn)
    end
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    [entry, videos] = load_videos_for_entry(id)

    if length(videos) > 0 do
      video  = Video
               |> Repo.get!(video_id)
               |> Repo.preload(:user)
               |> Video.with_vote_count
      voted = Entry.voted_video(entry, conn.assigns.current_user)

      render_entry(conn, entry, videos, video, voted)
    else
      redirect_no_videos(conn)
    end
  end

  defp load_videos_for_entry(entry_id) do
    entry       = Entry |> Entry.with_language |> Repo.get!(entry_id)
    video_query = Video.ordered_by_vote_for_entry(entry)
    videos      = video_query |> Repo.all |> Repo.preload(:user)
    [entry, videos]
  end

  defp render_entry(conn, entry, videos, video, voted) do
    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           voted_video: voted,
           searchbar: true,
           title: gettext("Sign for %{sign}", sign: entry.text)
         )
  end

  defp redirect_no_videos(conn) do
    conn
    |> put_flash(:info, gettext("No videos found."))
    |> redirect(to: "/")
  end

end
