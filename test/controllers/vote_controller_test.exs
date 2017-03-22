defmodule SignDict.VoteControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Vote

  describe "vote with logged in user" do
    test "it creates a vote and redirects to entry page" do
      video = insert(:video_with_entry)
      user = insert(:user)
      conn = build_conn()
               |> guardian_login(user)
               |> post(vote_path(build_conn(), :create, video))
      assert Vote |> Repo.get_by(%{user_id: user.id, video_id: video.id})
      assert redirected_to(conn) == entry_path(conn, :show, video.entry)
    end

    test "it can not create same vote more then once" do
      video = insert(:video_with_entry)
      user = insert(:user)
      vote = insert(:vote, video: video, user: user)
      conn = build_conn()
               |> guardian_login(user)
               |> post(vote_path(build_conn(), :create, video))
      assert  Vote |> Repo.aggregate(:count, :id) == 1
      assert Vote |> Repo.get(vote.id)
      assert redirected_to(conn) == entry_path(conn, :show, video.entry)
    end

    test "deletes existing vote" do
      video = insert(:video_with_entry)
      user = insert(:user)
      vote = insert(:vote, video: video, user: user)
      conn = build_conn()
               |> guardian_login(user)
               |> delete(vote_path(build_conn(), :delete, video))
      refute Vote |> Repo.get(vote.id)
      assert redirected_to(conn) == entry_path(conn, :show, video.entry)
    end

    test "does not delete vote of other user" do
      video = insert(:video_with_entry)
      user = insert(:user)
      insert(:vote, video: video, user: user)
      other_user = insert(:user)
      conn = build_conn()
               |> guardian_login(other_user)
               |> delete(vote_path(build_conn(), :delete, video))
      assert Vote |> Repo.get_by(%{user_id: user.id, video_id: video.id})
      assert redirected_to(conn) == entry_path(conn, :show, video.entry)
    end
  end

  describe "vote with logged out user" do
    test "does not create vote and redirect to login page" do
      video = insert(:video_with_entry)
      conn = build_conn() |> post(vote_path(build_conn(), :create, video))
      refute Vote |> Repo.get_by(%{video_id: video.id})
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "does not delete existing vote and redirect to login page" do
      video = insert(:video_with_entry)
      vote = insert(:vote, video: video)
      conn = build_conn() |> post(vote_path(build_conn(), :delete, video))
      assert Vote |> Repo.get(vote.id)
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end
end
