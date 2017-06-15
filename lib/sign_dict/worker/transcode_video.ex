defmodule SignDict.Worker.TranscodeVideo do
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, video_service \\ SignDict.Transcoder.JwPlayer,
              sleep_ms \\ 1000) do

    if Application.get_env(:sign_dict, :environment) != :dev do
      upload_and_transcode(video_id, video_service)
    end
    # Rate limit the workers, sadly i didn't find a better way :(
    Process.sleep(sleep_ms)
  end

  defp upload_and_transcode(video_id, video_service) do
    {:ok, video} = Video
                   |> Repo.get(video_id)
                   |> video_service.upload_video()
    Video.transcode(video)
  end
end
