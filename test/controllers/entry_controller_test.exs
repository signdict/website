defmodule SignDict.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "show/2 entry attributes" do
    test "it shows attributes of entry", %{conn: conn} do
      entry = insert(:entry_with_videos)
      conn = get conn, entry_path(conn, :show, entry)
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
    end
  end

end
