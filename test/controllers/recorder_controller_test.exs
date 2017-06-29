defmodule SignDict.RecorderControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test

  import SignDict.Factory

  describe "index/2" do
    test "it redirects if no entry is given", %{conn: conn} do
      conn = conn
             |> get(recorder_path(conn, :index))
      assert redirected_to(conn) == "/"
    end

    test "it redirects when entry is not found", %{conn: conn} do
      conn = conn
             |> get(recorder_path(conn, :index), entry_id: 1111111111)
      assert redirected_to(conn) == "/"
    end

    test "it renders the page if entry is present", %{conn: conn} do
      entry = insert(:entry)
      conn = conn
             |> get(recorder_path(conn, :index), entry_id: entry.id)
      assert html_response(conn, 200) =~ "Welcome"
    end
  end

  describe "new/2" do
    test "it redirects if no entry is given", %{conn: conn} do
      conn = conn
             |> get(recorder_path(conn, :new))
      assert redirected_to(conn) == "/"
    end

    test "it redirects when entry is not found", %{conn: conn} do
      conn = conn
             |> get(recorder_path(conn, :new), entry_id: 1111111111)
      assert redirected_to(conn) == "/"
    end

    test "it renders the page if entry is present", %{conn: conn} do
      entry = insert(:entry)
      conn = conn
             |> get(recorder_path(conn, :new), entry_id: entry.id)
      assert html_response(conn, 200)
    end
  end
end
