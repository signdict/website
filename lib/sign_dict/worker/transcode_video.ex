defmodule SignDict.Worker.TranscodeVideo do
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, video_service \\ SignDict.Transcoder.JwPlayer) do
    {:ok, video} = Video
                   |> Repo.get(video_id)
                   |> video_service.upload_video()
    Video.transcode(video)
  end
end
