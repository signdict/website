defmodule SignDictWeb.Plug.CurrentUser do
  @behaviour Plug
  import Plug.Conn
  import SignDict.Guardian.Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
