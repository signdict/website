defmodule Sign2Mint.EntryControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  describe "index/2" do
    test "it shows only entries for a certain letter", %{conn: conn} do
      insert(:entry_with_current_video, text: "Sloth")
      insert(:entry_with_current_video, text: "Marmot")

      domain = insert(:domain, domain: "sign2mint.local")
      insert(:entry_with_current_video, text: "Snake", domains: [domain])

      conn =
        conn
        |> get("http://sign2mint.local/" <> entry_path(conn, :index), letter: "S")

      body = html_response(conn, 200)
      assert body =~ "Snake"
      refute body =~ "Marmot"
      refute body =~ "Sloth"
    end
  end
end
