defmodule SignDict.FeelingLuckyControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Entry

  describe "index/2" do
    test "redirects to an random active entry", %{conn: conn} do
      insert(:entry_with_videos)
      entry = insert(:entry_with_videos)
              |> Entry.update_current_video
      conn  = get conn, feeling_lucky_path(conn, :index)
      assert redirected_to(conn) == entry_path(conn, :show, entry)
    end

    test "it returns nil if no entry is present", %{conn: conn} do
      conn = get conn, feeling_lucky_path(conn, :index)
      assert redirected_to(conn) == "/"
    end
  end
end
