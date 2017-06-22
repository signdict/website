defmodule SignDict.Api.SessionControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.User

  describe "create/2" do
    test "throws an error if login was wrong", %{conn: conn} do
      insert(:user)
      conn = post(conn, api_session_path(conn, :create),
                  %{"email" => "elisa@example.com",
                    "password" => "wrong_password"})
      json_response(conn, 401)
    end

    test "successfully login puts user into the session", %{conn: conn} do
      user = insert(:user)
      conn = post(conn, api_session_path(conn, :create),
                  %{"email" => user.email,
                    "password" => "correct_password"})
      json = json_response(conn, 200)
      assert json == %{"user" => %{
        "email" => user.email,
        "id"    => user.id,
        "name"  => user.name,
        "avatar"=> User.avatar_url(user)
      }}
      assert conn.assigns.current_user.id == user.id
    end
  end
end
