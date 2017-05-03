defmodule SignDict.SearchController do
  use SignDict.Web, :controller

  alias SignDict.Entry

  def index(conn, params) do
    [entries, title] = if params["q"] && String.length(params["q"]) > 0 do
      [
        Entry.search(Gettext.get_locale(SignDict.Gettext), params["q"]),
        gettext("Search results for %{query}", query: params["q"])
      ]
    else
      [[], gettext("Search")]
    end
    render conn, "index.html",
      conn: conn,
      searchbar: true,
      entries: entries,
      title: title
  end
end
