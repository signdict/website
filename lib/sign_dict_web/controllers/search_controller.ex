# TODO: ADD DOMAIN TEESTS
defmodule SignDictWeb.SearchController do
  use SignDictWeb, :controller

  alias SignDict.Entry

  def index(conn, params) do
    [entries, title] =
      if params["q"] && String.length(params["q"]) > 0 do
        [
          Entry.search_query(Gettext.get_locale(SignDictWeb.Gettext), conn.host, params["q"])
          |> Entry.with_current_video()
          |> SignDict.Repo.all(),
          gettext("Search results for %{query}", query: params["q"])
        ]
      else
        [[], gettext("Search")]
      end

    if perfect_match?(params["q"], entries) do
      redirect(conn, to: entry_path(conn, :show, List.first(entries)))
    else
      render(
        conn,
        "index.html",
        conn: conn,
        searchbar: true,
        entries: entries,
        title: title
      )
    end
  end

  defp perfect_match?(search, entries)

  defp perfect_match?(search, _entries) when is_nil(search) do
    false
  end

  defp perfect_match?(search, [entry]) do
    String.downcase(entry.text) == String.downcase(search)
  end

  defp perfect_match?(_search, _entries) do
    false
  end
end
