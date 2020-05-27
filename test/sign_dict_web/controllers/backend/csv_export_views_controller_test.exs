defmodule SignDictWeb.Backend.CSVExportViewsControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  import SignDict.Factory
  alias SignDict.Entry
  alias SignDict.Analytics

  describe "show/2" do
    test "it downloads a csv file", %{conn: conn} do
      user = insert(:user)

      entry =
        insert(:entry_with_videos, text: "Sloth")
        |> Entry.update_current_video()
        |> Repo.preload(:domains)

      video = entry.current_video

      video_count =
        Analytics.increase_video_count(
          List.first(entry.domains),
          "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",
          user,
          video
        )

      conn =
        conn
        |> guardian_login(insert(:statistic_user))
        |> get(backend_csv_export_views_path(conn, :show))

      assert response_content_type(conn, :csv) =~ "charset=utf-8"

      body = response(conn, 200)

      assert body ==
               "Entry ID,Video ID,Title,Description,Time\r\n#{entry.id},#{video.id},#{entry.text},#{
                 entry.description
               },#{Timex.format!(video_count.inserted_at, "%Y-%0m-%0dT%H:%M:%S", :strftime)}\r\n"
    end

    test "it redirects to root if the user is not allowed to do this", %{conn: conn} do
      insert(:domain, domain: "signdict.org")

      conn =
        conn
        |> guardian_login(insert(:user))
        |> get(backend_csv_export_views_path(conn, :show))

      assert redirected_to(conn, 302) == "/"
    end
  end
end
