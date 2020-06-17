defmodule SignDictWeb.Plug.SwitchLayout do
  @behaviour Plug
  import SignDictWeb.Helpers.LayoutHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    Phoenix.Controller.put_layout(
      conn,
      get_layout_for(conn.host, "app.html")
    )
  end
end
