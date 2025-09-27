defmodule SignDict.FeelingLuckyControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Entry

  describe "index/2" do
    test "redirects to an random active entry", %{conn: conn} do
      insert(:entry_with_videos)

      entry =
        insert(:entry_with_videos)
        |> Entry.update_current_video()

      conn = get(conn, feeling_lucky_path(conn, :index))
      assert redirected_to(conn) == Routes.entry_path(conn, :show, entry)
    end

    test "it returns nil if no entry is present", %{conn: conn} do
      conn = get(conn, feeling_lucky_path(conn, :index))
      assert redirected_to(conn) == "/"
    end

    test "does not redirect to an entry on a wrong domain", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Apple", domains: [domain])

      conn = get(conn, feeling_lucky_path(conn, :index))
      assert redirected_to(conn) == "/"
    end
  end
end
