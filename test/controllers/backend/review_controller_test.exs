defmodule SignDict.Backend.ReviewControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  import SignDict.Factory

  alias SignDict.Entry
  alias SignDict.User
  alias SignDict.Video

  describe "index/2" do
    test "it shows a list of videos in waiting_for_review state", %{conn: conn} do
      insert(:video_with_entry, state: "published")
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> get(backend_review_path(conn, :index))

      assert html_response(conn, 200)
      assert [video.id] == Enum.map(conn.assigns.videos.entries, fn x -> x.id end)
    end
  end

  describe "approve_video/2" do
    test "approves a video", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> post(backend_review_path(conn, :approve_video, video.id))

      assert redirected_to(conn) ==
               backend_entry_video_path(conn, :show, video.entry_id, video.id)

      assert get_flash(conn, :info) == "Video approved"
      assert Repo.get(Video, video.id).state == "published"
    end

    test "it sets the current_video_id of the entry", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn
      |> guardian_login(insert(:editor_user))
      |> post(backend_review_path(conn, :approve_video, video.id))

      entry = Repo.get(Entry, video.entry_id)
      assert entry.current_video_id == video.id
    end

    test "throws error if state can't be changed", %{conn: conn} do
      video = insert(:video_with_entry, state: "uploaded")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> post(backend_review_path(conn, :approve_video, video.id))

      assert redirected_to(conn) ==
               backend_entry_video_path(conn, :show, video.entry_id, video.id)

      assert get_flash(conn, :error) == "Video could not be approved"
      assert Repo.get(Video, video.id).state == "uploaded"
    end

    test "it sends the user an information about the approval", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn
      |> guardian_login(insert(:editor_user))
      |> post(backend_review_path(conn, :approve_video, video.id))

      assert_delivered_with(
        subject: "Your video was approved :)",
        to: [{video.user.name, video.user.email}]
      )
    end

    test "it sends the user an information in german if the users locale is de", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")
      User.changeset(video.user, %{locale: "de"}) |> Repo.update()

      conn
      |> guardian_login(insert(:editor_user))
      |> post(backend_review_path(conn, :approve_video, video.id))

      assert_delivered_with(
        subject: "Dein Video wurde freigegeben :)",
        to: [{video.user.name, video.user.email}]
      )
    end
  end

  describe "reject_video/2" do
    test "rejects a video", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> put(backend_review_path(conn, :reject_video, video.id), %{
          video: %{rejection_reason: "wrong sign"}
        })

      assert redirected_to(conn) ==
               backend_entry_video_path(conn, :show, video.entry_id, video.id)

      assert get_flash(conn, :info) == "Video rejected"
      video = Repo.get(Video, video.id)
      assert video.state == "rejected"
      assert video.rejection_reason == "wrong sign"
    end

    test "throws error if state can't be changed", %{conn: conn} do
      video = insert(:video_with_entry, state: "uploaded")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> put(backend_review_path(conn, :reject_video, video.id), %{
          video: %{rejection_reason: "wrong sign"}
        })

      assert redirected_to(conn) ==
               backend_entry_video_path(conn, :show, video.entry_id, video.id)

      assert get_flash(conn, :error) == "Video could not be rejected"
      assert Repo.get(Video, video.id).state == "uploaded"
    end

    test "throws error if reason is missing", %{conn: conn} do
      video = insert(:video_with_entry, state: "uploaded")

      conn =
        conn
        |> guardian_login(insert(:editor_user))
        |> put(backend_review_path(conn, :reject_video, video.id), %{
          video: %{rejection_reason: ""}
        })

      assert redirected_to(conn) ==
               backend_entry_video_path(conn, :show, video.entry_id, video.id)

      assert get_flash(conn, :error) == "Video could not be rejected"
      assert Repo.get(Video, video.id).state == "uploaded"
    end

    test "it sends the user an information about the rejection", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")

      conn
      |> guardian_login(insert(:editor_user))
      |> put(backend_review_path(conn, :reject_video, video.id), %{
        video: %{rejection_reason: "wrong sign"}
      })

      assert_delivered_with(
        subject: "Your video was rejected",
        to: [{video.user.name, video.user.email}]
      )
    end

    test "it sends the user an information in german if the users locale is de", %{conn: conn} do
      video = insert(:video_with_entry, state: "waiting_for_review")
      User.changeset(video.user, %{locale: "de"}) |> Repo.update()

      conn
      |> guardian_login(insert(:editor_user))
      |> put(backend_review_path(conn, :reject_video, video.id), %{
        video: %{rejection_reason: "wrong sign"}
      })

      assert_delivered_with(
        subject: "Dein Video wurde abgelehnt",
        to: [{video.user.name, video.user.email}]
      )
    end
  end
end
