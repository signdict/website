defmodule SignDict.Backend.ListEntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory
  alias SignDict.ListEntry

  @valid_attrs %{
    sort_order: 1
  }

  test "creates resource and redirects when data is valid", %{conn: conn} do
    list  = insert :list
    entry = insert :entry
    params = Map.merge(@valid_attrs, %{"entry_id" => entry.id})
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_list_list_entry_path(conn, :create, list), list_entry: params)
    assert redirected_to(conn) == backend_list_path(conn, :show, list)
    assert Repo.get_by(ListEntry, entry_id: entry.id, list_id: list.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    # TODO: fix this
    #
    #list  = insert :list
    #entry = insert :entry
    #params = %{"entry_id" => entry.id}
    #conn = conn
           #|> guardian_login(insert(:admin_user))
           #|> post(backend_list_list_entry_path(conn, :create, list), list_entry: params)
    #refute Repo.get_by(ListEntry, entry_id: entry.id, list_id: list.id)
  end

  test "deletes chosen resource", %{conn: conn} do
    list_entry = insert :list_entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> delete(backend_list_list_entry_path(conn, :delete, list_entry.list_id, list_entry))
    assert redirected_to(conn) == backend_list_path(conn, :show, list_entry.list_id)
    refute Repo.get(ListEntry, list_entry.id)
  end
end
