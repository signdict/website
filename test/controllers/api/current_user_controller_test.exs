defmodule SignDict.Api.CurrentUserControllerTest do
  use SignDict.ConnCase

  alias SignDict.User

  import SignDict.Factory

  describe "show/2" do
    test "renders an empty hash if user is not logged in", %{conn: conn} do
      conn = get(conn, api_current_user_path(conn, :show))
      body = json_response(conn, 200)
      assert body == %{}
    end

    test "renders a user hash if the user is logged in", %{conn: conn} do
      user = insert :user
      conn = conn
           |> guardian_login(user)
           |> get(api_current_user_path(conn, :show))
      body = json_response(conn, 200)
      assert body == %{"user" => %{
        "email" => user.email,
        "id"    => user.id,
        "name"  => user.name,
        "avatar"=> User.avatar_url(user)
      }}
    end
  end
end
