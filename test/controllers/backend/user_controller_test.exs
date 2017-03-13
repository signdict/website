defmodule SignDict.Backend.UserControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.User
  @valid_attrs %{
    email: "homer@example.com", password: "mypasswordisalie", password_confirmation: "mypasswordisalie",
    name: "Homer Simpson", biography: "Working in a nuclear power plant",
  }
  @invalid_attrs %{
    password: "anotherpassword", password_confirmation: "doesnotfit"
  }

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get conn, backend_user_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_user_path(conn, :index))
    assert redirected_to(conn, 401) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_user_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_user_path(conn, :create), user: @valid_attrs)
    assert redirected_to(conn) == backend_user_path(conn, :index)
    assert Repo.get_by(User, email: "homer@example.com")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_user_path(conn, :create), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_user_path(conn, :show, -1))
    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_user_path(conn, :edit, user))
    assert html_response(conn, 200) =~ "Edit User"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = insert :user

    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_user_path(conn, :update, user), user: @valid_attrs)
    assert redirected_to(conn) == backend_user_path(conn, :show, user)
    assert Repo.get_by(User, email: "homer@example.com")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert :user
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_user_path(conn, :update, user),
                  user: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit User"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = insert :user
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> delete(backend_user_path(conn, :delete, user))
    assert redirected_to(conn) == backend_user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
