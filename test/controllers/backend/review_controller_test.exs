defmodule SignDict.Backend.ReviewControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "index/2" do
    test "it shows a list of videos in waiting_for_review state", %{conn: conn} do
      insert(:video_with_entry, state: "published")
      video = insert(:video_with_entry, state: "waiting_for_review")
      conn = conn
           |> guardian_login(insert(:editor_user))
           |> get(backend_review_path(conn, :index))
      assert html_response(conn, 200)
      assert [video.id] == Enum.map(
        conn.assigns.videos.entries,
        fn(x) -> x.id end
      )
    end
  end
end
