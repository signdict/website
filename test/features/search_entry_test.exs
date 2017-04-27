defmodule SignDict.SearchEntryTest do
  use SignDict.AcceptanceCase, async: true
  import SignDict.Factory

  alias SignDict.Entry

  test "Search for a sign", %{session: session} do
    train_entry = insert(:entry, %{text: "train"})
    insert(:video_published, %{entry: train_entry})
    Entry.update_current_video(train_entry)

    house_entry = insert(:entry, %{text: "house"})
    insert(:video_published, %{entry: house_entry})
    Entry.update_current_video(house_entry)

    session
    |> visit("/")
    |> find(Query.css(".so-landing--search"), fn(form) ->
      form
      |> fill_in(Query.text_field("q"), with: "tr")
      |> click(Query.button("Search ›"))
    end)
    |> find(Query.css(".so-search-result--headline"), fn(headline) ->
      headline
      |> has_text?("One search result for")
    end)
    |> click(Query.css(".so-search-result--link"))

    assert current_path(session) == entry_path(SignDict.Endpoint, :show, train_entry)
  end
end
