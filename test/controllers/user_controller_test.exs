defmodule SignDict.UserControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  @valid_attrs %{
    email: "elisa@example.com",
    password: "valid_password",
    password_confirmation: "valid_password",
    name: "some content",
    biography: "some content"
  }
  @invalid_attrs %{}

  describe "new/2" do
    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "Email"
    end
  end

  describe "create/2" do
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

  describe "show/2" do
    test "it shows the user even if logged out", %{conn: conn} do
      user = insert :user
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ user.name
    end
  end

  describe "edit/2" do
    test "it redirects if user is not the same user", %{conn: conn} do
      insert :user
      conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :index))

      assert redirected_to(conn, 401) == "/"
    end

    test "it redirects if user is not logged in", %{conn: conn} do
      user = insert :user
      conn = get conn, user_path(conn, :edit, user)
      assert redirected_to(conn, 401) == "/"
    end

    test "it lets you edit the user if you are that user", %{conn: conn} do
      user = insert :user
      conn = conn
           |> guardian_login(user)
           |> get(user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Email"
    end
  end

  describe "update/2" do
    test "it redirects if user is not the same user", %{conn: conn} do
      user = insert :user
      conn = conn
           |> guardian_login(insert(:user))
           |> patch(user_path(conn, :update, user), user: @valid_attrs)
      assert redirected_to(conn, 401) == "/"
    end

    test "it redirects if user is not logged in", %{conn: conn} do
      user = insert :user
      conn = conn
           |> patch(user_path(conn, :update, user), user: @valid_attrs)
      assert redirected_to(conn, 401) == "/"
    end

    test "it lets you update the user if you are that user", %{conn: conn} do
      user = insert :user
      conn = conn
           |> guardian_login(user)
           |> patch(user_path(conn, :update, user), user: @valid_attrs)
      assert redirected_to(conn) == user_path(conn, :show, user)
      assert Repo.get_by(SignDict.User, email: "elisa@example.com")
    end
  end
end
