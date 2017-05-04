defmodule SignDict.Worker.TranscodeVideo do
  alias SignDict.Repo

  def perform(video_id) do
    video = Repo.get(SignDict.Video, video_id)
    SignDict.Transcoder.JwPlayer.upload_video(video)
  end
end
