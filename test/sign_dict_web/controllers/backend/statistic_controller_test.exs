defmodule SignDictWeb.Backend.StatisticControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: true

  import SignDict.Factory

  describe "index/2" do
    test "it shows the index page", %{conn: conn} do
      conn =
        conn
        |> guardian_login(insert(:statistic_user))
        |> get(backend_statistic_path(conn, :index))

      assert html_response(conn, 200)

      body = html_response(conn, 200)
      assert body =~ "Statistic"
      refute body =~ "Entries"
    end

    test "it redirects to root if the user is not allowed to do this", %{conn: conn} do
      conn =
        conn
        |> guardian_login(insert(:user))
        |> get(backend_statistic_path(conn, :index))

      assert redirected_to(conn, 302) == "/"
    end
  end
end
