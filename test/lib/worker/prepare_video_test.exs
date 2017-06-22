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

    test "it calls the video service to upload the video" do
      video_id = insert(:video, state: "uploaded", metadata: %{"source_webm" => "folder/file.webm"}).id
      PrepareVideo.perform(video_id, SystemMock)
      assert_received {:system_call, "ffmpeg", [
        "-i", "./test/uploads/video_upload/folder/file.webm",
        "-r", "30000/1001",
        "-pix_fmt", "yuv420p",
        "-vsync", "1",
        "-g", "60",
        "-y",
        "./test/uploads/video_upload/folder/file.mp4"
      ]}
      assert Repo.get(Video, video_id).state == "prepared"
    end

    test "it adds a transcoder job to the queue" do
      video_id = insert(:video, state: "uploaded", metadata: %{"source_webm" => "folder/file.webm"}).id
      PrepareVideo.perform(video_id, SystemMock)
      assert_received {:mock_exq, "transcoder", SignDict.Worker.TranscodeVideo, [^video_id]}
    end
  end
end
