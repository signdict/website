defmodule SignDict.SearchController do
  use SignDict.Web, :controller

  alias SignDict.Entry

  def index(conn, params) do
    entries = if params["q"] && String.length(params["q"]) > 0 do
      Entry.search(params["q"])
    else
      []
    end
    render conn, "index.html", conn: conn, searchbar: true, entries: entries
  end
end
