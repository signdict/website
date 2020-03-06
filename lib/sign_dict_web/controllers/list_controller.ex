# TODO: ADD DOMAIN TEESTS
defmodule SignDictWeb.ListController do
  @moduledoc """
  """
  use SignDictWeb, :controller

  alias SignDict.List
  alias SignDict.Services.OpenGraph

  plug :load_resource, model: List

  def show(conn, _params) do
    list = conn.assigns.list
    entries = List.entries(list)

    render(
      conn,
      "show.html",
      list: list,
      entries: entries,
      searchbar: true,
      ogtags: OpenGraph.to_metadata(list),
      title: gettext("List \"%{name}\"", name: list.name)
    )
  end
end
