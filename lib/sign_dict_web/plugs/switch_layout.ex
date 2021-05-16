defmodule SignDictWeb.Plug.SwitchLayout do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    Phoenix.Controller.put_layout(
      conn,
      {SignDictWeb.LayoutView, "app.html"}
    )
  end
end
