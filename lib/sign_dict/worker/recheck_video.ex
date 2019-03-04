defmodule SignDict.Worker.RecheckVideo do
  @moduledoc """
  Sadly JWPlayer does not have a status that
  shows us that all video qualities have been
  transcoded. It just returns a "ready" status
  as soon as one quality is available. This
  Worker will recheck the status and updates
  the video with all currently available files.
  It is triggered in the SignDict.Worker.CheckVideoStatus
  10 minutes after the ready event was fired.
  This gives JWPlayer enough time to finish
  everything.
  """
  require Bugsnex

  alias SignDict.Repo
  alias SignDict.Video

  @process_sleep_time 100

  def perform(
        video_id,
        video_service \\ SignDict.Transcoder.JwPlayer,
        sleep_ms \\ @process_sleep_time
      ) do
    Bugsnex.handle_errors %{video_id: video_id} do
      # Rate limit the workers, sadly i didn't find a better way :(
      Process.sleep(sleep_ms)

      video = Repo.get(Video, video_id)

      if video do
        video_service.check_status(video)
      else
        :deleted
      end
    end
  end
end
