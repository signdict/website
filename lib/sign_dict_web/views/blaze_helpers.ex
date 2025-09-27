defmodule SignDictWeb.BlazeHelpers do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  def nav_active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])

    if path == current_path do
      "c-nav__item--active"
    else
      nil
    end
  end

  def nav_active_link(conn, text, path, opts \\ []) do
    class =
      [Keyword.get(opts, :class), "c-nav__item", nav_active_class(conn, path)]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    opts =
      opts
      |> Keyword.put(:class, class)
      |> Keyword.put(:to, path)

    link(text, opts)
  end
end
