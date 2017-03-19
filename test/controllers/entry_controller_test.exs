defmodule SignDict.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "show/2 entry attributes" do
    test "it shows attributes of entry", %{conn: conn} do
      entry = insert(:entry)
      conn = get conn, entry_path(conn, :show, entry)
      assert html_response(conn, 200) =~ entry.description
      assert html_response(conn, 200) =~ entry.text
      assert html_response(conn, 200) =~ entry.type
    end
  end

  describe "show/2 accociated language attributes" do
    test "it shows long_name of association", %{conn: conn} do
      entry = insert(:entry)
      conn = get conn, entry_path(conn, :show, entry)
      assert html_response(conn, 200) =~ entry.language.long_name
    end
  end

  describe "show/2 accociated video attributes" do
    test "it shows names of all accociated videos of entry", %{conn: conn} do
      entry = insert(:entry_with_videos)
      conn = get conn, entry_path(conn, :show, entry)
      for id <- Enum.map(entry.videos, fn(video) -> video.id end) do
        assert html_response(conn, 200) =~ "#{id}"
      end
    end
  end
end
