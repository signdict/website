defmodule SignDict.PageControllerTest do
  use SignDict.ConnCase
  import SignDict.Factory

  describe "index/2" do
    test "should render the index page", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "About SignDict"
    end

    test "it should not find something with a wrong domain", %{conn: conn} do
      domain = insert(:domain, domain: "example.com")
      insert(:entry_with_current_video, text: "Apple", domains: [domain])
      insert(:entry_with_current_video, text: "Tree")
      conn = get(conn, "/")

      assert conn.assigns.sign_count == 4
      assert html_response(conn, 200) =~ "About SignDict"
    end
  end
end
