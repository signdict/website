defmodule SignDictWeb.Plug.AllowedForBackend do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  import SignDictWeb.Gettext, only: [gettext: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    if Canada.Can.can?(conn.assigns.current_user, :show_backend, %{}) do
      conn
    else
      conn
      |> put_flash(:error, gettext("You are not allowed to do this."))
      |> redirect(to: "/")
      |> halt()
    end
  end
end
