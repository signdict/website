defmodule SignDict.Backend.ListControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory
  alias SignDict.List

  @valid_attrs %{
    name: "some content",
    description: "some description",
    sort_order: "manual",
    type: "categorie-list"
  }
  @invalid_attrs %{
    sort_order: "invalid_order"
  }

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get(conn, backend_list_path(conn, :index))
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:user))
      |> get(backend_list_path(conn, :index))

    assert redirected_to(conn, 302) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_list_path(conn, :index))

    assert html_response(conn, 200) =~ "Listing lists"
  end

  test "renders form for new resources", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_list_path(conn, :new))

    assert html_response(conn, 200) =~ "New list"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(backend_list_path(conn, :create), list: @valid_attrs)

    assert redirected_to(conn) == backend_list_path(conn, :index)
    assert Repo.get_by(List, name: "some content")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(backend_list_path(conn, :create), list: @invalid_attrs)

    assert html_response(conn, 200) =~ "New list"
  end

  test "shows chosen resource", %{conn: conn} do
    list = insert(:list)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_list_path(conn, :show, list))

    assert html_response(conn, 200) =~ "List"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_list_path(conn, :show, 999_999))

    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    list = Repo.insert!(%List{})

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_list_path(conn, :edit, list))

    assert html_response(conn, 200) =~ "Edit list"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    list = insert(:list)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(backend_list_path(conn, :update, list), list: @valid_attrs)

    assert redirected_to(conn) == backend_list_path(conn, :show, Repo.get(SignDict.List, list.id))
    assert Repo.get_by(List, name: "some content")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    list = insert(:list)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(backend_list_path(conn, :update, list), list: @invalid_attrs)

    assert html_response(conn, 200) =~ "Edit list"
  end

  test "deletes chosen resource", %{conn: conn} do
    list = insert(:list)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> delete(backend_list_path(conn, :delete, list))

    assert redirected_to(conn) == backend_list_path(conn, :index)
    refute Repo.get(List, list.id)
  end
end
