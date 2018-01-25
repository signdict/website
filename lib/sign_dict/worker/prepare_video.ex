defmodule SignDict.Worker.PrepareVideo do
  require Bugsnex

  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, system \\ System) do
    Bugsnex.handle_errors %{video_id: video_id} do
      convert_to_mp4(video_id, system)

      if Application.get_env(:sign_dict, :environment) != :dev do
        queue = Application.get_env(:sign_dict, :queue)[:library]
        queue.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video_id])
      end
    end
  end

  defp convert_to_mp4(video_id, system) do
    video = Repo.get!(Video, video_id)
    {start_time, _reminder} = Float.parse(video.metadata["video_start_time"])
    {end_time, _reminder} = Float.parse(video.metadata["video_end_time"])

    {_result, 0} =
      system.cmd("ffmpeg", [
        "-ss",
        Float.to_string(start_time),
        "-i",
        "#{Video.file_path(video.metadata["source_webm"])}",
        "-r",
        "30000/1001",
        "-pix_fmt",
        "yuv420p",
        "-vsync",
        "1",
        "-g",
        "60",
        "-y",
        "-t",
        Float.to_string(end_time - start_time),
        video |> target_filename |> Video.file_path()
      ])

    {:ok, _video} =
      video
      |> add_mp4_source_to_metadata
      |> Video.prepare()
  end

  defp add_mp4_source_to_metadata(video) do
    Video.changeset_transcoder(video, %{
      metadata:
        Map.merge(video.metadata, %{
          "source_mp4" => target_filename(video)
        })
    })
  end

  defp target_filename(video) do
    video.metadata["source_webm"]
    |> String.replace(~r/\.webm$/, ".mp4")
  end
end
