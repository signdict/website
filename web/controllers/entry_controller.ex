defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  def show(conn, %{"id" => id}) do
    entry = Entry |> Entry.with_language |> Repo.get!(id)

    video_query = Video.ordered_by_vote_for_entry(entry)
    [video | videos] = video_query |> Repo.all |> Repo.preload(:user)

    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           searchbar: true,
           videos: videos,
         )
  end

  def show(conn, %{"entry_id" => id, "video_id" => video_id}) do
    entry = Entry |> Entry.with_language |> Repo.get!(id)

    video_query = Video.ordered_by_vote_for_entry(entry)
    videos = video_query
             |> where([v], v.id != ^video_id)
             |> Repo.all
             |> Repo.preload(:user)
    video = Video |> Repo.get!(video_id) |> Repo.preload(:user)

    render(conn, "show.html",
           layout: {SignDict.LayoutView, "empty.html"},
           entry: entry,
           video: video,
           videos: videos,
           searchbar: true
         )
  end
end
