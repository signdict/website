defmodule SignDict.SearchEntryTest do
  use SignDict.AcceptanceCase
  import SignDict.Factory

  alias SignDict.Entry

  test "Search for a sign", %{session: session} do
    domain = insert(:domain, domain: "localhost")

    kid_entry = insert(:entry, %{text: "kid", domains: [domain]})
    insert(:video_published, %{entry: kid_entry})
    Entry.update_current_video(kid_entry)

    school_entry = insert(:entry, %{text: "school", domains: [domain]})
    insert(:video_published, %{entry: school_entry})
    Entry.update_current_video(school_entry)

    session
    |> visit("/")
    |> resize_window(1200, 600)
    |> find(Query.css(".so-landing--search"), fn form ->
      form
      |> fill_in(Query.text_field("q"), with: "ki")
      |> click(Query.button("Search ›"))
    end)
    |> find(Query.css(".so-search-result--headline"), fn headline ->
      headline
      |> has_text?("One search result for")
    end)
    |> click(Query.css(".so-search-result--link"))

    assert current_path(session) == entry_path(SignDictWeb.Endpoint, :show, kid_entry)
  end
end
