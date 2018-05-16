defmodule SignDict.Worker.CheckVideoStatus do
  require Bugsnex

  @process_sleep_time 100
  # 60 seconds
  @check_transcoder_result_time 60
  # 10 minutes
  @recheck_transcoder_result_time 60 * 10

  alias SignDictWeb.Email
  alias SignDictWeb.Mailer
  alias SignDict.Repo
  alias SignDict.Video

  def perform(
        video_id,
        video_service \\ SignDict.Transcoder.JwPlayer,
        exq \\ Exq,
        sleep_ms \\ @process_sleep_time
      ) do
    Bugsnex.handle_errors %{video_id: video_id} do
      video = Repo.get(SignDict.Video, video_id)
      status = video_service.check_status(video)

      # Rate limit the workers, sadly i didn't find a better way :(
      Process.sleep(sleep_ms)

      process_video(video, status, exq)
    end
  end

  defp process_video(video, state, exq)

  defp process_video(video, :transcoding, exq) do
    exq.enqueue_in(
      Exq,
      "transcoder",
      @check_transcoder_result_time,
      SignDict.Worker.CheckVideoStatus,
      [video.id]
    )

    :transcoding
  end

  defp process_video(video, :done, exq) do
    exq.enqueue_in(
      Exq,
      "transcoder",
      @recheck_transcoder_result_time,
      SignDict.Worker.RecheckVideo,
      [video.id]
    )

    {:ok, video} = Video.wait_for_review(video)

    video
    |> Email.video_waiting_for_review()
    |> Mailer.deliver_later()

    :done
  end

  defp process_video(_video, _state, _exq) do
    {:error, :unknown_status}
  end
end
