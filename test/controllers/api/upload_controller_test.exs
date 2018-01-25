defmodule SignDict.Api.UploadControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Video

  describe "create/2" do
    setup do
      working_path =
        Path.join([
          System.tmp_dir(),
          "upload_" <> Integer.to_string(System.unique_integer([:positive]))
        ])

      video_file = Path.join([working_path, "Zug.mp4"])
      File.mkdir(working_path)
      File.cp("test/fixtures/videos/Zug.mp4", video_file)

      on_exit(fn ->
        File.rm_rf(Path.expand(Application.get_env(:sign_dict, :upload_path)))
        File.rm_rf(working_path)
      end)

      %{
        entry: insert(:entry),
        user: insert(:user),
        upload: %Plug.Upload{path: video_file, filename: "Zug.mp4"}
      }
    end

    test "uploads a video for a signed in user", %{
      conn: conn,
      entry: entry,
      user: user,
      upload: upload
    } do
      conn =
        conn
        |> guardian_login(user)
        |> post(api_upload_path(conn, :create), %{
          video: upload,
          entry_id: entry.id,
          start_time: 0,
          end_time: 2
        })

      video = Repo.get_by!(Video, user_id: user.id)
      video_id = video.id
      assert_received {:mock_exq, "transcoder", SignDict.Worker.PrepareVideo, [^video_id]}

      video_file = Video.file_path(video.metadata["source_webm"])
      assert File.exists?(video_file)
      assert video.metadata["video_start_time"] == 0
      assert video.metadata["video_end_time"] == 2

      json = json_response(conn, 200)

      assert json == %{
               "video" => %{
                 "entry_id" => entry.id,
                 "user_id" => user.id,
                 "state" => "uploaded",
                 "id" => video.id
               }
             }
    end

    test "uploads for a freshly registered user", %{
      conn: conn,
      entry: entry,
      user: user,
      upload: upload
    } do
      conn =
        conn
        |> assign(:registered_user_id, user.id)
        |> post(api_upload_path(conn, :create), %{
          video: upload,
          entry_id: entry.id,
          start_time: 0,
          end_time: 2
        })

      video = Repo.get_by!(Video, user_id: user.id)
      video_id = video.id
      assert_received {:mock_exq, "transcoder", SignDict.Worker.PrepareVideo, [^video_id]}

      video_file =
        Path.join([
          Application.get_env(:sign_dict, :upload_path),
          "video_upload",
          video.metadata["source_webm"]
        ])

      assert File.exists?(video_file)

      json = json_response(conn, 200)

      assert json == %{
               "video" => %{
                 "entry_id" => entry.id,
                 "user_id" => user.id,
                 "state" => "uploaded",
                 "id" => video.id
               }
             }
    end

    test "failes when entry id is wrong", %{conn: conn, user: user, upload: upload} do
      conn =
        conn
        |> guardian_login(user)
        |> post(api_upload_path(conn, :create), %{
          video: upload,
          entry_id: -1,
          start_time: 0,
          end_time: 2
        })

      count =
        Video
        |> where(user_id: ^user.id)
        |> Repo.aggregate(:count, :id)

      assert count == 0

      json = json_response(conn, 404)
      assert json == %{"error" => "Could not store video"}
    end
  end
end
