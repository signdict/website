defmodule SignDict.Worker.TranscodeVideoTest do
  use ExUnit.Case, async: true
  import SignDict.Factory

  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Worker.TranscodeVideo

  setup do
    Application.ensure_all_started(SignDict.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SignDict.Repo)
  end

  describe "perform/2" do
    defmodule VideoServiceMock do
      @behaviour SignDict.Transcoder.API
      def upload_video(video) do
        send self(), {:transcode_video, video.id}
        {:ok, video}
      end
      def check_status(video) do
        send self(), {:check_status, video.id}
        :transcoding
      end
    end

    test "it calls the video service to upload the video" do
      video_id = insert(:video, state: "uploaded").id
      TranscodeVideo.perform(video_id, VideoServiceMock, 0)
      assert_received {:transcode_video, ^video_id}
      assert Repo.get(Video, video_id).state == "transcoding"
    end

  end
end

