defmodule SignDict.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "show/2 entry attributes" do

    setup do
      entry = insert(:entry)
      {:ok, user_1}  = %{build(:user) | name: "User 1"} |> Repo.insert
      {:ok, user_2}  = %{build(:user) | name: "User 2"} |> Repo.insert
      {:ok, user_3}  = %{build(:user) | name: "User 3"} |> Repo.insert
      {:ok, video_1} = %{build(:video) | state: "published", user: user_1, entry: entry } |> Repo.insert
      {:ok, video_2} = %{build(:video) | state: "published", user: user_2, entry: entry } |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_1, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_2, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_3, video: video_2} |> Repo.insert

      {
        :ok,
        entry: entry, user_1: user_1, user_2: user_2, user_3: user_3,
        video_1: video_1, video_2: video_2
      }
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
