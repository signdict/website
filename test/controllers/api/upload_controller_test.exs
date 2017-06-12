defmodule SignDict.Api.UploadControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Video

  describe "create/2" do

    setup do
      %{
        entry:  insert(:entry),
        user:   insert(:user),
        upload: %Plug.Upload{path: "test/fixtures/videos/Zug.mp4", filename: "Zug.mp4"}
      }
    end

    test "uploads a video for a signed in user", %{conn: conn, entry: entry, user: user, upload: upload} do
      conn = conn
             |> guardian_login(user)
             |> post(api_upload_path(conn, :create),
                    %{video: upload, entry_id: entry.id})

      video = Repo.get_by!(Video, user_id: user.id)

      json = json_response(conn, 200)
      assert json == %{
        "video" => %{
          "entry_id" => entry.id,
          "user_id"  => user.id,
          "state"    => "created",
          "id"       => video.id
        }
      }
    end

    test "uploads for a freshly registered user", %{conn: conn, entry: entry, user: user, upload: upload} do
      conn = conn
             |> assign(:registered_user_id, user.id)
             |> post(api_upload_path(conn, :create),
                    %{video: upload, entry_id: entry.id})

      video = Repo.get_by!(Video, user_id: user.id)

      json = json_response(conn, 200)
      assert json == %{
        "video" => %{
          "entry_id" => entry.id,
          "user_id"  => user.id,
          "state"    => "created",
          "id"       => video.id
        }
      }
    end

    test "failes when entry id is wrong", %{conn: conn, user: user, upload: upload} do
      conn = conn
             |> guardian_login(user)
             |> post(api_upload_path(conn, :create),
                    %{video: upload, entry_id: -1})

      count = Video
              |> where(user_id: ^user.id)
              |> Repo.aggregate(:count, :id)
      assert count == 0

      json = json_response(conn, 404)
      assert json == %{"error" => "Could not store video"}
    end

  end
end
