defmodule SignDict.Worker.CheckVideoStatusTest do
  use SignDict.ModelCase
  use Bamboo.Test

  import SignDict.Factory

  alias SignDict.Entry
  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Worker.CheckVideoStatus

  defmodule ExqMock do
    def enqueue_in(_arg1, _arg2, time, module, params) do
      send(self(), {:enqueue_in, time, module, params})
    end
  end

  defmodule VideoServiceMockTranscoding do
    @behaviour SignDict.Transcoder.API
    def upload_video(_video), do: :sent

    def check_status(video) do
      send(self(), {:check_status, video.id})
      :transcoding
    end
  end

  defmodule VideoServiceMockDone do
    @behaviour SignDict.Transcoder.API
    def upload_video(_video), do: :sent

    def check_status(video) do
      send(self(), {:check_status, video.id})
      :done
    end
  end

  defmodule VideoServiceMockError do
    @behaviour SignDict.Transcoder.API
    def upload_video(_video), do: :sent

    def check_status(video) do
      send(self(), {:check_status, video.id})
      :error
    end
  end

  describe "perform/2" do
    test "if the video is still transcoding retry another time" do
      video_id = insert(:video, %{state: "transcoding"}).id

      assert CheckVideoStatus.perform(video_id, VideoServiceMockTranscoding, ExqMock, 0) ==
               :transcoding

      assert Repo.get(Video, video_id).state == "transcoding"
      assert_received {:check_status, ^video_id}
      assert_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
      refute_received {:enqueue_in, 600, SignDict.Worker.RecheckVideo, [^video_id]}
    end

    test "it set the the video to waiting_for_review if it is done" do
      video_id = insert(:video_with_entry, %{state: "transcoding"}).id
      assert CheckVideoStatus.perform(video_id, VideoServiceMockDone, ExqMock, 0) == :done
      assert Repo.get(Video, video_id).state == "waiting_for_review"
      assert_received {:check_status, ^video_id}
      refute_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
      assert_received {:enqueue_in, 600, SignDict.Worker.RecheckVideo, [^video_id]}
      assert_received {:enqueue_in, 1200, SignDict.Worker.RecheckVideo, [^video_id]}
      assert_received {:enqueue_in, 1800, SignDict.Worker.RecheckVideo, [^video_id]}
    end

    test "it publishes the video if it is done and set to auto_publish" do
      video_id = insert(:video_with_entry, %{auto_publish: true, state: "transcoding"}).id
      assert CheckVideoStatus.perform(video_id, VideoServiceMockDone, ExqMock, 0) == :done

      video = Repo.get(Video, video_id)
      entry = Repo.get(Entry, video.entry_id)

      assert video.state == "published"
      assert entry.current_video_id == video_id
      assert_received {:check_status, ^video_id}
      refute_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
      assert_received {:enqueue_in, 600, SignDict.Worker.RecheckVideo, [^video_id]}

      refute_email_delivered_with(
        subject: "New video added for \"some content\"",
        to: [{"Bodo", "mail@signdict.org"}]
      )
    end

    test "it sends an email and notifies the users" do
      editor = insert(:editor_user)
      video_id = insert(:video_with_entry, %{state: "transcoding"}).id
      assert CheckVideoStatus.perform(video_id, VideoServiceMockDone, ExqMock, 0) == :done

      assert_email_delivered_with(
        subject: "New video added for \"some content\"",
        to: [{"Bodo", "mail@signdict.org"}],
        bcc: [{editor.name, editor.email}]
      )
    end

    test "it returns an error if the status code is unknown" do
      video_id = insert(:video, %{state: "transcoding"}).id

      assert CheckVideoStatus.perform(video_id, VideoServiceMockError, ExqMock, 0) ==
               {:error, :unknown_status}

      assert Repo.get(Video, video_id).state == "transcoding"
      assert_received {:check_status, ^video_id}
      refute_received {:enqueue_in, 60, SignDict.Worker.CheckVideoStatus, [^video_id]}
    end
  end
end
