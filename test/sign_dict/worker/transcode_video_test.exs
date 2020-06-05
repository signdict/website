defmodule SignDict.Worker.TranscodeVideoTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Worker.TranscodeVideo

  describe "perform/2" do
    defmodule ExqMockLater do
      def enqueue_in(_arg1, _arg2, time, module, params) do
        send(self(), {:enqueue_in, time, module, params})
      end
    end

    defmodule VideoServiceMock do
      @behaviour SignDict.Transcoder.API
      def upload_video(video) do
        send(self(), {:transcode_video, video.id})
        {:ok, video}
      end

      def check_status(video) do
        send(self(), {:check_status, video.id})
        :transcoding
      end
    end

    defmodule VideoServiceFailedMock do
      @behaviour SignDict.Transcoder.API
      def upload_video(video) do
        send(self(), {:transcode_video, video.id})
        {:error, "this failed"}
      end

      def check_status(video) do
        send(self(), {:check_status, video.id})
        :transcoding
      end
    end

    test "it calls the video service to upload the video" do
      video_id = insert(:video, state: "uploaded").id
      TranscodeVideo.perform(video_id, VideoServiceMock, 0, ExqMockLater)
      assert_received {:transcode_video, ^video_id}
      assert Repo.get(Video, video_id).state == "transcoding"
    end

    test "it tries to upload again in 10 minutes if the upload failed" do
      video_id = insert(:video, state: "uploaded").id
      TranscodeVideo.perform(video_id, VideoServiceFailedMock, 0, ExqMockLater)
      assert_received {:transcode_video, ^video_id}
      assert Repo.get(Video, video_id).state == "uploaded"
      assert_received {:enqueue_in, 600, SignDict.Worker.TranscodeVideo, [^video_id]}
    end
  end
end
