defmodule SignDict.SessionControllerTest do
  use SignDict.ConnCase
  import SignDict.Factory

  describe "new/2" do
    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, session_path(conn, :new))
      assert html_response(conn, 200) =~ "Email"
    end
  end

  describe "create/2" do
    test "rerenders new.html if params are missing", %{conn: conn} do
      conn =
        post(conn, session_path(conn, :create), %{"session" => %{"email" => "", "password" => ""}})

      assert html_response(conn, 200) =~ "Email"
    end

    test "throws an error if login was wrong", %{conn: conn} do
      insert(:user)

      conn =
        post(conn, session_path(conn, :create), %{
          "session" => %{"email" => "elisa@example.com", "password" => "wrong_password"}
        })

      assert html_response(conn, 200) =~ "Email"
    end

    test "successfully login puts user into the session", %{conn: conn} do
      user = insert(:user)

      conn =
        post(conn, session_path(conn, :create), %{
          "session" => %{"email" => user.email, "password" => "correct_password"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "Successfully signed in"
    end
  end

  describe "delete/2" do
    test "delete a session", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> guardian_login(user)
        |> delete(session_path(conn, :delete, user))

      assert get_flash(conn, :info) == "Successfully signed out"
      refute SignDict.Guardian.Plug.authenticated?(conn)
    end
  end
end
