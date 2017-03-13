defmodule SignDict.Backend.DashboardControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get conn, backend_dashboard_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_dashboard_path(conn, :index))
    assert redirected_to(conn, 401) == "/"
  end

  test "shows dashboard page", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_dashboard_path(conn, :index))
    assert html_response(conn, 200) =~ "Dashboard"
  end

end
