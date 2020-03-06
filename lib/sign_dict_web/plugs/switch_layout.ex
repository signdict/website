defmodule SignDictWeb.Plug.SwitchLayout do
  import SignDictWeb.Helpers.LayoutHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    Phoenix.Controller.put_layout(
      conn,
      {SignDictWeb.LayoutView, get_layout_for(conn.host, "app.html")}
    )
  end
end
