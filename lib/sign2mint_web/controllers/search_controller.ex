defmodule Sign2MintWeb.SearchController do
  use Sign2MintWeb, :controller

  alias SignDict.Entry
  alias SignDict.Video

  def index(conn, params) do
    [result, title] =
      if params["q"] && String.length(params["q"]) > 0 do
        [
          Entry.search_query(Gettext.get_locale(SignDictWeb.Gettext), conn.host, params["q"])
          |> Entry.with_videos()
          |> Entry.with_current_video()
          |> with_filters("verwendungskontext", params["verwendungskontext"])
          |> with_filters("fachgebiet", params["fachgebiet"])
          |> with_filters("ursprung", params["ursprung"])
          |> SignDict.Repo.paginate(Map.merge(params, %{page_size: 20})),
          gettext("Search results for %{query}", query: params["q"])
        ]
      else
        [%{entries: [], total_entries: 0, total_pages: 0}, gettext("Search")]
      end

    if perfect_match?(params["q"], result.entries) do
      redirect(conn, to: entry_path(conn, :show, List.first(result.entries)))
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

  defp with_filters(query, name, values)

  defp with_filters(query, _name, nil) do
    query
  end

  defp with_filters(query, _name, []) do
    query
  end

  defp with_filters(query, _name, "") do
    query
  end

  defp with_filters(query, name, values) do
    conditions =
      Enum.reduce(values, false, fn value, condition ->
        dynamic(
          [entry, domain, video],
          fragment("?->'filter_data'->? @> ?", video.metadata, ^name, ^value) or ^condition
        )
      end)

    from entry in query,
      join: video in Video,
      on: entry.id == video.entry_id,
      where: ^conditions
  end
end
