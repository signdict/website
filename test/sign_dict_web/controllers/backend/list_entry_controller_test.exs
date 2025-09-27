defmodule SignDictWeb.Backend.ListEntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory
  alias SignDict.List
  alias SignDict.ListEntry

  @valid_attrs %{
    sort_order: 1
  }

  test "creates resource and redirects when data is valid", %{conn: conn} do
    list = insert(:list)
    entry = insert(:entry_with_current_video)
    insert(:video_published, %{entry: entry})
    SignDict.Entry.update_current_video(entry)

    params = Map.merge(@valid_attrs, %{"entry_id" => entry.id})

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(backend_list_list_Routes.entry_path(conn, :create, list), list_entry: params)

    assert redirected_to(conn) == backend_list_path(conn, :show, list.id)
    assert Repo.get_by(ListEntry, entry_id: entry.id, list_id: list.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    list = insert(:list)
    entry = insert(:entry)
    params = %{"entry_id" => entry.id}

    conn
    |> guardian_login(insert(:admin_user))
    |> post(backend_list_list_Routes.entry_path(conn, :create, list), list_entry: params)

    refute Repo.get_by(ListEntry, entry_id: entry.id, list_id: list.id)
  end

  test "deletes chosen resource", %{conn: conn} do
    list_entry = insert(:list_entry)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> delete(backend_list_list_Routes.entry_path(conn, :delete, list_entry.list_id, list_entry))

    assert redirected_to(conn) == backend_list_path(conn, :show, list_entry.list_id)
    refute Repo.get(ListEntry, list_entry.id)
  end

  test "moves list entry up", %{conn: conn} do
    list = insert(:list, sort_order: "manual")
    list_entry_1 = insert(:list_entry, list: list, sort_order: 1)
    list_entry_2 = insert(:list_entry, list: list, sort_order: 2)

    conn
    |> guardian_login(insert(:admin_user))
    |> post(backend_list_list_Routes.entry_path(conn, :move_up, list, list_entry_2))

    assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
             {list_entry_2.id, 1},
             {list_entry_1.id, 2}
           ]
  end

  test "moves list entry down", %{conn: conn} do
    list = insert(:list, sort_order: "manual")
    list_entry_1 = insert(:list_entry, list: list, sort_order: 1)
    list_entry_2 = insert(:list_entry, list: list, sort_order: 2)

    conn
    |> guardian_login(insert(:admin_user))
    |> post(backend_list_list_Routes.entry_path(conn, :move_down, list, list_entry_1))

    assert Enum.map(List.entries(list), &{&1.id, &1.sort_order}) == [
             {list_entry_2.id, 1},
             {list_entry_1.id, 2}
           ]
  end
end
