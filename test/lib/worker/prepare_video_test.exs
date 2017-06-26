defmodule SignDict.Worker.PrepareVideoTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Worker.PrepareVideo

  describe "perform/2" do
    defmodule SystemMock do
      def cmd(command, params) do
        send self(), {:system_call, command, params}
        {"yes", 0}
      end
    end

    setup do
      %{video: insert(:video_with_entry, state: "uploaded", metadata: %{
        "source_webm" => "folder/file.webm",
        "video_start_time" => "1.5",
        "video_end_time"   => "3.2",
      })}
    end

    test "it calls the video service to upload the video", %{video: video} do
      PrepareVideo.perform(video.id, SystemMock)
      assert_received {:system_call, "ffmpeg", [
        "-ss", "1.5",
        "-i", "./test/uploads/video_upload/folder/file.webm",
        "-r", "30000/1001",
        "-pix_fmt", "yuv420p",
        "-vsync", "1",
        "-g", "60",
        "-y",
        "-t", "1.7000000000000002",
        "./test/uploads/video_upload/folder/file.mp4"
      ]}
      assert Repo.get(Video, video.id).state == "prepared"
    end

    test "adds the mp4 to the metadata", %{video: video} do
      PrepareVideo.perform(video.id, SystemMock)
      assert Repo.get(Video, video.id).metadata["source_mp4"] == "folder/file.mp4"
    end

    test "it adds a transcoder job to the queue", %{video: video} do
      PrepareVideo.perform(video.id, SystemMock)
      video_id = video.id
      assert_received {:mock_exq, "transcoder", SignDict.Worker.TranscodeVideo, [^video_id]}
    end

    test "it also works when giving integers and not floats as string" do
      video = insert(:video_with_entry, state: "uploaded", metadata: %{
        "source_webm" => "folder/file.webm",
        "video_start_time" => "1",
        "video_end_time"   => "3",
      })
      PrepareVideo.perform(video.id, SystemMock)
      assert Repo.get(Video, video.id).state == "prepared"
    end
  end
end
