defmodule SignDict.Worker.RecheckVideoTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.Worker.RecheckVideo

  defmodule VideoServiceMockDone do
    @behaviour SignDict.Transcoder.API
    def upload_video(_video), do: :sent

    def check_status(video) do
      send(self(), {:check_status, video.id})
      :done
    end
  end

  describe "perform/2" do
    test "it publishes the video if it is done" do
      video_id = insert(:video_with_entry, %{state: "transcoding"}).id
      assert RecheckVideo.perform(video_id, VideoServiceMockDone, 0) == :done
      assert_received {:check_status, ^video_id}
    end
  end
end
