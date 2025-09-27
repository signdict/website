defmodule SignDictWeb.SearchController do
  use SignDictWeb, :controller
  

  alias SignDict.Entry

  def index(conn, params) do
    [result, title] =
      if params["q"] && String.length(params["q"]) > 0 do
        [
          Entry.search_query(Gettext.get_locale(SignDictWeb.Gettext), conn.host, params["q"])
          |> Entry.with_current_video()
          |> SignDict.Repo.paginate(params),
          gettext("Search results for %{query}", query: params["q"])
        ]
      else
        [%{entries: [], total_entries: 0, total_pages: 0}, gettext("Search")]
      end

    if perfect_match?(params["q"], result.entries) do
      redirect(conn, to: Router.Helpers.entry_path(conn, :show, List.first(result.entries)))
    else
      render(
        conn,
        "index.html",
        conn: conn,
        searchbar: true,
        result: result,
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
