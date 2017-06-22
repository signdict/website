defmodule SignDict.Worker.PrepareVideo do
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, system \\ System) do
   convert_to_mp4(video_id, system)
   if Application.get_env(:sign_dict, :environment) != :dev do
      queue = Application.get_env(:sign_dict, :queue)[:library]
      queue.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video_id])
    end
  end

  defp convert_to_mp4(video_id, system) do
    video         = Repo.get!(Video, video_id)
    # TODO: start/end_time
    {_result, 0}  = system.cmd("ffmpeg", [
      "-i", "#{Video.file_path(video.metadata["source_webm"])}",
      "-r", "30000/1001",
      "-pix_fmt", "yuv420p",
      "-vsync", "1",
      "-g", "60",
      "-y",
      target_filename(video)
    ])
    {:ok, _video} = Video.prepare(video)
  end

  defp target_filename(video) do
    video.metadata["source_webm"]
    |> String.replace(~r/\.webm$/, ".mp4")
    |> Video.file_path
  end
end
