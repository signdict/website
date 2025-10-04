defmodule SignDictWeb.Backend.DashboardControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get(conn, Helpers.backend_dashboard_path(conn, :index))
    assert redirected_to(conn) == Helpers.session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:user))
      |> get(Helpers.backend_dashboard_path(conn, :index))

    assert redirected_to(conn, 302) == "/"
  end

  test "shows dashboard page if user is admin", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_dashboard_path(conn, :index))

    assert html_response(conn, 200) =~ "dashboard"
  end

  test "shows dashboard page if user is editor", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:editor_user))
      |> get(Helpers.backend_dashboard_path(conn, :index))

    assert html_response(conn, 200) =~ "dashboard"
  end
end
