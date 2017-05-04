defmodule SignDict.Worker.CheckVideoStatus do
  alias SignDict.Repo

  def perform(video_id) do
    video = Repo.get(SignDict.Video, video_id)
    status = SignDict.Transcoder.JwPlayer.check_video_status(video)

    if status == :transcoding do
      # reschedule check
    else
      # set live
    end
  end
end
