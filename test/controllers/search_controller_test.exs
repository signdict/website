defmodule SignDict.SearchControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Entry

  test "it should show an empty page when no query is given", %{conn: conn} do
    conn  = get(conn, search_path(conn, :index))
    assert html_response(conn, 200) =~ "Search"
  end

  test "it should show an empty page when no result was found", %{conn: conn} do
    conn  = get(conn, search_path(conn, :index, q: "language"))
    assert conn.assigns.entries == []
    assert html_response(conn, 200) =~ "Search results for lang"
  end

  test "it should show a list of results if something was found", %{conn: conn} do
    entry = insert(:entry_with_videos, text: "language")
            |> Entry.update_current_video
    conn  = get(conn, search_path(conn, :index, q: "lang"))
    assert conn.assigns.entries == [entry]
    assert html_response(conn, 200) =~ "Search results for lang"
  end

  test "it should redirect to entry if only one match was found and its an exact match", %{conn: conn} do
    entry = insert(:entry_with_videos, text: "language")
            |> Entry.update_current_video
    conn  = get(conn, search_path(conn, :index, q: "language"))
    assert redirected_to(conn) == entry_path(conn, :show, entry)
  end

  test "it should also redirect to entry if case is not equal", %{conn: conn} do
    entry = insert(:entry_with_videos, text: "language")
            |> Entry.update_current_video
    conn  = get(conn, search_path(conn, :index, q: "Language"))
    assert redirected_to(conn) == entry_path(conn, :show, entry)
  end
end
