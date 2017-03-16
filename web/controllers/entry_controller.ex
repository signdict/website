defmodule SignDict.EntryController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.Entry
  alias SignDict.Repo

  def show(conn, %{"id" => id}) do
    entry = Entry
      |> Entry.with_language
      |> Entry.with_videos
      |> Repo.get!(id)
    render(conn, "show.html", entry: entry)
  end
end
