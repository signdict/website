defmodule SignDict.PostgresQueryHelperTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Video

  test "it returns the correct status code" do
    video = insert(:video_with_entry, %{metadata: %{"jw_video_id" => "4OCxwoAI"}})
    IO.inspect SignDict.Transcoder.JwPlayer.check_status(video)
    video = Repo.get(Video, video.id)
    IO.inspect(video)
  end

end
