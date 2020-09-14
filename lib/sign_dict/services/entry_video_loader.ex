defmodule SignDict.Services.EntryVideoLoader do
  import Ecto.Query

  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video

  def load_videos_for_entry(conn, id: entry_id, video_id: video_id, filter_videos: should_filter) do
    result = load_videos_for_entry(conn, id: entry_id, video_id: video_id)

    if should_filter do
      Map.merge(result, %{videos: filter_videos(result)})
    else
      result
    end
  end

  def load_videos_for_entry(conn, id: entry_id, video_id: video_id) do
    result = do_load_entry_and_videos(entry_id, conn.host, conn.assigns.current_user)
    video = do_load_video(%{video_id: video_id, videos: result.videos})
    Map.merge(result, %{conn: conn, video: video})
  end

  def load_videos_for_entry(conn, id: entry_id, filter_videos: should_filter) do
    result = load_videos_for_entry(conn, id: entry_id)

    if should_filter do
      Map.merge(result, %{videos: filter_videos(result)})
    else
      result
    end
  end

  def load_videos_for_entry(conn, id: entry_id) do
    result = do_load_entry_and_videos(entry_id, conn.host, conn.assigns.current_user)

    video =
      if !is_nil(result[:entry]) do
        do_load_voted_video(%{voted: result.voted, videos: result.videos})
      end

    Map.merge(result, %{conn: conn, video: video})
  end

  defp filter_videos(%{video: source_video, videos: videos}) do
    Enum.filter(videos, fn video ->
      video.id != source_video.id
    end)
  end

  defp do_load_video(%{video_id: video_id, videos: videos}) when length(videos) > 0 do
    Video
    |> Repo.get(video_id)
    |> Repo.preload(:user)
    |> Video.with_vote_count()
  end

  defp do_load_video(_args) do
    nil
  end

  defp do_load_voted_video(params = %{voted: %{id: video_id}, videos: videos})
       when length(videos) > 0 and not is_nil(video_id) do
    Video.with_vote_count(params.voted)
  end

  defp do_load_voted_video(%{videos: videos}) when length(videos) > 0 do
    videos
    |> List.first()
    |> Video.with_vote_count()
  end

  defp do_load_voted_video(_args) do
    nil
  end

  def do_load_entry_and_videos(entry_id, domain, current_user) do
    query =
      from(entry in Entry,
        join: domain in assoc(entry, :domains),
        where: domain.domain == ^domain
      )

    query
    |> Entry.with_language()
    |> Repo.get(entry_id)
    |> do_fetch_videos_for_entry(current_user)
  end

  defp do_fetch_videos_for_entry(entry, _current_user) when is_nil(entry) do
    %{entry: nil, videos: []}
  end

  defp do_fetch_videos_for_entry(entry, current_user) do
    video_query = Video.ordered_by_vote_for_entry(entry)
    videos = video_query |> Repo.all() |> Repo.preload(:user)
    voted = Entry.voted_video(entry, current_user)
    %{entry: entry, videos: videos, voted: voted}
  end
end
