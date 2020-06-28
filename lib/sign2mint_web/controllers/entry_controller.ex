defmodule Sign2MintWeb.EntryController do
  @moduledoc """
  """
  use Sign2MintWeb, :controller

  alias SignDict.Entry

  def index(conn, params) do
    letter = params["letter"] || "A"

    entries =
      Entry.active_entries(conn.host)
      |> Entry.with_videos()
      |> Entry.for_letter(letter)
      |> SignDict.Repo.paginate(Map.merge(params, %{page_size: 20}))

    render(conn, "index.html",
      entries: entries,
      searchbar: true,
      letter: letter,
      title: gettext("All entries")
    )
  end
end
