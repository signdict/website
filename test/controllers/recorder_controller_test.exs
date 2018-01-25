defmodule SignDict.RecorderControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test

  import SignDict.Factory

  describe "index/2" do
    test "it redirects when entry is not found", %{conn: conn} do
      conn =
        conn
        |> get(recorder_path(conn, :index, 1_111_111_111))

      assert redirected_to(conn) == "/"
    end

    test "it renders the page if entry is present", %{conn: conn} do
      entry = insert(:entry)

      conn =
        conn
        |> get(recorder_path(conn, :index, entry.id))

      assert html_response(conn, 200) =~ "Welcome"
    end
  end

  describe "new/2" do
    test "it renders the page if entry is present", %{conn: conn} do
      entry = insert(:entry)

      conn =
        conn
        |> get(recorder_path(conn, :new, entry.id))

      assert html_response(conn, 200) =~ "data-entry-id=\"#{entry.id}\""
    end
  end
end
