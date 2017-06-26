defmodule SignDict.Worker.CheckVideoStatus do
  require Bugsnex

  alias SignDict.Email
  alias SignDict.Mailer
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, video_service \\ SignDict.Transcoder.JwPlayer,
              exq \\ Exq, sleep_ms \\ 1000) do
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
    exq.enqueue_in(Exq, "transcoder", 60,
                   SignDict.Worker.CheckVideoStatus, [video.id])
    :transcoding
  end
  defp process_video(video, :done, _exq) do
    {:ok, video} = Video.wait_for_review(video)
    video
    |> Email.video_waiting_for_review
    |> Mailer.deliver_later
    :done
  end
  defp process_video(_video, _state, _exq) do
    {:error, :unknown_status}
  end

end
