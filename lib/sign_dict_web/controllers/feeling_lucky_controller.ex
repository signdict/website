defmodule SignDictWeb.FeelingLuckyController do
  @moduledoc """
  """
  use SignDictWeb, :controller

  alias SignDict.Entry

  def index(conn, _params) do
    entry = load_entry(conn.host)

    if entry != nil do
      redirect(conn, to: entry_path(conn, :show, entry))
    else
      redirect(conn, to: "/")
    end
  end

  defp load_entry(domain, count \\ 0) do
    count = count + 1

    entry =
      Entry.active_entries(domain)
      |> offset(
        fragment(
          "floor(random()*(SELECT count(entries.id) FROM entries join domains_entries on (entries.id = domains_entries.entry_id) join domains on (domains_entries.domain_id = domains.id) where domains.domain = ?))",
          ^domain
        )
      )
      |> first
      |> Repo.one()

    if entry == nil && count < 10 do
      load_entry(domain, count)
    else
      entry
    end
  end
end
