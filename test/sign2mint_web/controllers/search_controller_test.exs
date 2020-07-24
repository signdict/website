defmodule Sign2Mint.SearchControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Entry

  test "it should show an empty page when no query is given", %{conn: conn} do
    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index))
    assert html_response(conn, 200) =~ "Search"
  end

  test "it should show an empty page when no result was found", %{conn: conn} do
    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "language"))
    assert conn.assigns.result.entries == []
    assert html_response(conn, 200) =~ "Search results for lang"
  end

  test "it should show a list of results if something was found", %{conn: conn} do
    domain = insert(:domain, domain: "sign2mint.local")

    entry =
      insert(:entry_with_videos, text: "language", domains: [domain])
      |> Entry.update_current_video()

    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "lang"))
    assert Enum.map(conn.assigns.result.entries, & &1.id) == [entry.id]
    assert html_response(conn, 200) =~ "Search results for lang"
  end

  test "it should not use stopwords", %{conn: conn} do
    domain = insert(:domain, domain: "sign2mint.local")

    entry =
      insert(:entry_with_videos, text: "but", domains: [domain])
      |> Entry.update_current_video()

    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "but"))
    assert redirected_to(conn) == entry_path(conn, :show, entry)
  end

  test "it should redirect to entry if only one match was found and its an exact match", %{
    conn: conn
  } do
    domain = insert(:domain, domain: "sign2mint.local")

    entry =
      insert(:entry_with_videos, text: "language", domains: [domain])
      |> Entry.update_current_video()

    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "language"))
    assert redirected_to(conn) == entry_path(conn, :show, entry)
  end

  test "it should also redirect to entry if case is not equal", %{conn: conn} do
    domain = insert(:domain, domain: "sign2mint.local")

    entry =
      insert(:entry_with_videos, text: "language", domains: [domain])
      |> Entry.update_current_video()

    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "Language"))
    assert redirected_to(conn) == entry_path(conn, :show, entry)
  end

  test "it should not find something with a wrong domain", %{conn: conn} do
    domain = insert(:domain, domain: "example.com")
    insert(:entry_with_current_video, text: "Apple", domains: [domain])

    conn = get(conn, "http://sign2mint.local/" <> search_path(conn, :index, q: "Apple"))
    assert conn.assigns.result.entries == []

    assert html_response(conn, 200) =~ "Search results for Apple"
  end

  describe "filtering" do
    setup do
      domain = insert(:domain, domain: "sign2mint.local")
      entry = insert(:entry, text: "Apple", domains: [domain])

      insert(:video,
        state: "published",
        entry: entry,
        metadata: %{filter_data: %{fachgebiet: "Chemie", anwendungsbereich: "Schule"}}
      )

      Entry.update_current_video(entry)

      entry2 = insert(:entry, text: "Aubergine", domains: [domain])

      insert(:video,
        state: "published",
        entry: entry2,
        metadata: %{filter_data: %{fachgebiet: "Biologie", anwendungsbereich: "Schule"}}
      )

      Entry.update_current_video(entry2)

      {:ok, entry: entry, entry2: entry2}
    end

    test "it should filter for one criteria", %{conn: conn, entry: entry} do
      conn =
        get(
          conn,
          "http://sign2mint.local/" <>
            search_path(conn, :index, q: "A", fachgebiet: ["Chemie"])
        )

      assert Enum.map(conn.assigns.result.entries, fn entry -> entry.id end) == [entry.id]
      assert html_response(conn, 200) =~ "Search results for A"
    end

    test "it should filter for two criteria", %{conn: conn, entry: entry} do
      conn =
        get(
          conn,
          "http://sign2mint.local/" <>
            search_path(conn, :index,
              q: "A",
              fachgebiet: ["Chemie"],
              anwendungsbereich: ["Schule"]
            )
        )

      assert Enum.map(conn.assigns.result.entries, fn entry -> entry.id end) == [entry.id]
      assert html_response(conn, 200) =~ "Search results for A"
    end

    test "it should use or for two criteria in the same key", %{
      conn: conn,
      entry: entry,
      entry2: entry2
    } do
      conn =
        get(
          conn,
          "http://sign2mint.local/" <>
            search_path(conn, :index,
              q: "A",
              fachgebiet: ["Chemie", "Biologie"],
              anwendungsbereich: ["Schule"]
            )
        )

      assert Enum.map(conn.assigns.result.entries, fn entry -> entry.id end) == [
               entry.id,
               entry2.id
             ]

      assert html_response(conn, 200) =~ "Search results for A"
    end

    test "it should work if filter is empty", %{conn: conn, entry: entry, entry2: entry2} do
      conn =
        get(
          conn,
          "http://sign2mint.local/" <>
            search_path(conn, :index,
              q: "A",
              fachgebiet: []
            )
        )

      assert Enum.map(conn.assigns.result.entries, fn entry -> entry.id end) == [
               entry.id,
               entry2.id
             ]

      assert html_response(conn, 200) =~ "Search results for A"
    end

    test "it should work if filter is nil", %{conn: conn, entry: entry, entry2: entry2} do
      conn =
        get(
          conn,
          "http://sign2mint.local/" <>
            search_path(conn, :index,
              q: "A",
              fachgebiet: nil
            )
        )

      assert Enum.map(conn.assigns.result.entries, fn entry -> entry.id end) == [
               entry.id,
               entry2.id
             ]

      assert html_response(conn, 200) =~ "Search results for A"
    end
  end
end
