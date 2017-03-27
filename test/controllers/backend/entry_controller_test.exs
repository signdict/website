defmodule SignDict.Backend.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Entry
  @valid_attrs %{
    text: "house", description: "building",
    type: "word"
  }
  @invalid_attrs %{
    type: "nonexisting"
  }

  test "it redirects when no entry logged in", %{conn: conn} do
    conn = get conn, backend_entry_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin entry logged in", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_entry_path(conn, :index))
    assert redirected_to(conn, 401) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing entries"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_path(conn, :new))
    assert html_response(conn, 200) =~ "New entry"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_entry_path(conn, :create), entry: @valid_attrs)
    assert redirected_to(conn) == backend_entry_path(conn, :index)
    assert Repo.get_by(Entry, text: "house")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_entry_path(conn, :create), entry: @invalid_attrs)
    assert html_response(conn, 200) =~ "New entry"
  end

  test "shows chosen resource", %{conn: conn} do
    entry = insert :entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_path(conn, :show, entry))
    assert html_response(conn, 200) =~ "Entry"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_path(conn, :show, -1))
    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    entry = Repo.insert! %Entry{}
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_path(conn, :edit, entry))
    assert html_response(conn, 200) =~ "Edit entry"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    entry = insert :entry

    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_entry_path(conn, :update, entry), entry: @valid_attrs)
    assert redirected_to(conn) == backend_entry_path(conn, :show, entry)
    assert Repo.get_by(Entry, text: "house")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    entry = insert :entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_entry_path(conn, :update, entry),
                  entry: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit entry"
  end

  test "deletes chosen resource", %{conn: conn} do
    entry = insert :entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> delete(backend_entry_path(conn, :delete, entry))
    assert redirected_to(conn) == backend_entry_path(conn, :index)
    refute Repo.get(Entry, entry.id)
  end
end
