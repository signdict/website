defmodule SignDict.ListControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test, shared: :true

  import SignDict.Factory

  describe "show/2" do
    test "renders all entries with current_videos", %{conn: conn} do
      list = insert :list, sort_order: "alphabetical_desc"

      entry_1 = insert :entry_with_current_video, text: "Cherry"
      entry_2 = insert :entry_with_current_video, text: "Banana"
      entry_3 = insert :entry_with_current_video, text: "Apple"
      entry_without_video = insert :entry, text: "Remove Me"

      insert :list_entry, list: list, sort_order: 1, entry: entry_1
      insert :list_entry, list: list, sort_order: 2, entry: entry_2
      insert :list_entry, list: list, sort_order: 3, entry: entry_3
      insert :list_entry, list: list, sort_order: 4, entry: entry_without_video

      conn = get(conn, list_path(conn, :show, list.id))
      assert html_response(conn, 200) =~ ~r/Cherry.*Banana.*Apple/s
      refute html_response(conn, 200) =~ ~r/Remove Me/
    end
  end

end
