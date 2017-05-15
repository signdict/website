defmodule SignDict.Transcoder.JwPlayer do
  @behaviour SignDict.Transcoder.API

  alias Ecto.Changeset
  alias JwPlayer.Client
  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Worker.CheckVideoStatus

  def upload_video(video, http_client \\ HTTPoison, exq \\ Exq) do
    json = upload_video_to_jw(video, http_client)

    if json["status"] == "ok" do
        video
        |> Video.changeset_transcoder
        |> add_jw_answer_to_video(json)
        |> add_jw_video_id_to_video(json)
        |> Repo.update
        exq.enqueue_in(Exq, "transcoder", 60, CheckVideoStatus, [video.id])
        {:ok, video}
    else
        video
        |> Video.changeset_transcoder
        |> add_jw_answer_to_video(json)
        |> Repo.update
        {:error, video}
    end
  end

  def check_status(video, http_client \\ HTTPoison) do
    json   = video
           |> load_video_status(http_client)
    status = json["video"]["status"]
    cond do
      status == "ready" ->
        fetch_urls_and_update_video(video, http_client)
        :done
      Enum.member?(["created", "processing", "updating"], status) ->
        store_response_in_video(video, json)
        :transcoding
      true ->
        store_response_in_video(video, json)
        :error
    end
  end

  defp store_response_in_video(video, json) do
    video
    |> Video.changeset_transcoder
    |> add_jw_answer_to_video(json)
    |> Repo.update
  end

  defp upload_video_to_jw(video, http_client) do
    response = "/videos/create"
               |> Client.sign_url(%{
                 title: "video-#{video.id}",
                 download_url: "https://beta.signdict.org/uploads/video_upload/#{video.metadata["source_mp4"]}"
               })
               |> http_client.get!
    Poison.decode! response.body
  end

  defp load_video_status(video, http_client) do
    response = "/videos/show"
               |> Client.sign_url(%{video_key: video.metadata["jw_video_id"]})
               |> http_client.get!
    Poison.decode! response.body
  end

  defp fetch_urls_and_update_video(video, http_client) do
    result = http_client.get!("https://cdn.jwplayer.com/v2/media/#{video.metadata["jw_video_id"]}")
    json = Poison.decode!(result.body)
    changeset = Video.changeset_transcoder(video, %{
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
    add_metadata(video, %{"jw_status" => json})
  end

  defp add_jw_video_id_to_video(video, json) do
    add_metadata(video, %{"jw_video_id" => json["video"]["key"]})
  end

  defp add_metadata(video, data) do
    {_source, metadata} = Changeset.fetch_field(video, :metadata)
    changeset = Video.changeset_transcoder(video,
                  %{metadata: Map.merge(metadata || %{}, data)})
    changeset
  end
end
