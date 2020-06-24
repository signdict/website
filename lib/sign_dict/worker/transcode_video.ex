defmodule SignDict.Worker.TranscodeVideo do
  alias SignDict.Repo
  alias SignDict.Video

  # 10 minutes
  @retry_upload 60 * 10

  def perform(
        video_id,
        video_service \\ SignDict.Transcoder.JwPlayer,
        sleep_ms \\ 1000,
        exq \\ Exq
      ) do
    upload_and_transcode(video_id, video_service, exq)
    # Rate limit the workers, sadly i didn't find a better way :(
    Process.sleep(sleep_ms)
  rescue
    exception ->
      Bugsnag.report(exception, metadata: %{video_id: video_id})
  end

  defp upload_and_transcode(video_id, video_service, exq) do
    result =
      Video
      |> Repo.get(video_id)
      |> video_service.upload_video()

    case result do
      {:ok, video} ->
        Video.transcode(video)

      _ ->
        if Application.get_env(:sign_dict, :environment) != :dev do
          exq.enqueue_in(Exq, "transcoder", @retry_upload, SignDict.Worker.TranscodeVideo, [
            video_id
          ])
        end
    end
  end
end
