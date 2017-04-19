defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  def show(conn, %{"id" => id}) do
    entry  = Entry |> Entry.with_language |> Repo.get!(id)
    videos = load_videos(entry)
    voted  = Entry.voted_video(entry, conn.assigns.current_user)
    video  = if voted.id, do: voted, else: List.first(videos)

    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           voted_video: voted,
           searchbar: true
         )
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    entry  = Entry |> Entry.with_language |> Repo.get!(id)
    videos = load_videos(entry)
    video  = Video |> Repo.get!(video_id) |> Repo.preload(:user)

    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           voted_video: Entry.voted_video(entry, conn.assigns.current_user),
           searchbar: true
         )
  end

  defp load_videos(entry) do
    video_query = Video.ordered_by_vote_for_entry(entry)
    video_query
    |> Repo.all
    |> Repo.preload(:user)
  end

end
