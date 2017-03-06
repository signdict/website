defmodule SignDict.UserControllerTest do
  use SignDict.ConnCase

  @valid_attrs %{
    email: "elisa@example.com",
    password: "valid_password",
    password_confirmation: "valid_password",
    name: "some content",
    biography: "some content"
  }
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, user_path(conn, :new))
    assert html_response(conn, 200) =~ "Email"
  end

  test "creates a user with valid form data", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @valid_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
    assert Repo.get_by(SignDict.User, email: "elisa@example.com")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "Email"
  end
end
