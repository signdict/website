defmodule SignDict.Worker.TranscodeVideo do
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, video_service \\ SignDict.Transcoder.JwPlayer,
              sleep_ms \\ 1000) do
    {:ok, video} = Video
                   |> Repo.get(video_id)
                   |> video_service.upload_video()
    Video.transcode(video)
    # Rate limit the workers, sadly i didn't find a better way :(
    Process.sleep(sleep_ms)
  end
end
