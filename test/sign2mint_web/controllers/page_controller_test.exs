defmodule Sign2Mint.PageControllerTest do
  use SignDict.ConnCase

  describe "index/2" do
    test "should render the index page", %{conn: conn} do
      conn = get(conn, "http://sign2mint.local/")
      assert html_response(conn, 200) =~ "Über Sign2MINT"
    end
  end
end
