defmodule SignDict.Transcoder.JwPlayer do
  @behaviour SignDict.Transcoder.API

  alias SignDict.Repo
  alias SignDict.Video

  def upload_video(video) do
    {:ok, video}
  end

  def check_status(video, http_client \\ HTTPoison) do
    json   = video
           |> load_video_status(http_client)
    status = json["video"]["status"]
    cond do
      status == "ready" ->
        update_video(video, http_client)
        :done
      Enum.member?(["created", "processing", "updating"], status) ->
        video |> add_jw_answer_to_video(json) |> Repo.update
        :transcoding
      true ->
        video |> add_jw_answer_to_video(json) |> Repo.update
        :error
    end
  end

  defp load_video_status(video, http_client) do
    response = "/videos/show"
               |> JwPlayer.Client.sign_url(%{video_key: video.metadata["jw_video_id"]})
               |> http_client.get!
    Poison.decode! response.body
  end

  defp update_video(video, http_client) do
    result = http_client.get!("https://cdn.jwplayer.com/v2/media/#{video.metadata["jw_video_id"]}")
    json = Poison.decode!(result.body)
    changeset = Video.changeset(video, %{
                                  video_url: get_video_from_response(json),
                                  thumbnail_url: get_thumbnail_from_response(json)
                                })
    changeset
    |> add_jw_answer_to_video(json)
    |> Repo.update
  end

  defp get_video_from_response(json) do
    video = List.first(json["playlist"])
    best_source = video["sources"]
                  |> filter_supported_types
                  |> sort_sources_by_width
                  |> List.last
    best_source["file"]
  end

  defp sort_sources_by_width(sources) do
    sources
    |> Enum.sort_by(fn(source) ->
      source["width"]
    end)
  end

  defp filter_supported_types(sources) do
    sources
    |> Enum.filter(fn(source) ->
      source["type"] == "video/mp4"
    end)
  end

  defp get_thumbnail_from_response(json) do
    video = List.first(json["playlist"])
    video["image"]
  end

  defp add_jw_answer_to_video(video, json) do
    {_source, metadata} = Ecto.Changeset.fetch_field(video, :metadata)
    changeset = Video.changeset(video, %{metadata: Map.merge(metadata || %{}, %{"jw_status" => json})})
    changeset
  end

end
