defmodule SignDict.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "show/2 entry attributes" do

    setup do
      entry = insert(:entry)
      user_1  = insert(:user, %{name: "User 1"})
      user_2  = insert(:user, %{name: "User 2"})
      user_3  = insert(:user, %{name: "User 3"})
      video_1 = insert(:video, %{state: "published", user: user_1, entry: entry})
      video_2 = insert(:video, %{state: "published", user: user_2, entry: entry})
      {:ok, _vote}    = %SignDict.Vote{user: user_1, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_2, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_3, video: video_2} |> Repo.insert

      {
        :ok,
        entry: entry, user_1: user_1, user_2: user_2, user_3: user_3,
        video_1: video_1, video_2: video_2
      }
    end

    test "it redirect if the entry does not have any videos and no video id is given", %{conn: conn} do
      entry = insert(:entry)
      conn = get conn, entry_path(conn, :show, entry)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "No videos found."
    end

    test "it redirect if the entry does not have any videos and a video id is given", %{conn: conn} do
      entry = insert(:entry)
      conn = get conn, entry_video_path(conn, :show, entry, 1)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "No videos found."
    end

    test "shows the highest voted video if no video is given", %{conn: conn, entry: entry} do
      conn = get conn, entry_path(conn, :show, entry)
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 1"
    end


    test "shows the voted video if the user voted one", %{conn: conn, entry: entry, user_3: user} do
      conn = conn
           |> guardian_login(user)
           |> get(entry_path(conn, :show, entry))
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 2"
    end

    test "shows a specific video if given in the url", %{conn: conn, entry: entry, video_2: video} do
      conn = get conn, entry_video_path(conn, :show, entry, video)
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
      assert html_response(conn, 200) =~ "User 2"
    end
  end
end
