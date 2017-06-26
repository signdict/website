defmodule SignDict.Plug.AllowedForBackend do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  import SignDict.Gettext, only: [gettext: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    if !Canada.Can.can?(conn.assigns.current_user, :show_backend, %{}) do
      conn
      |> put_flash(:error, gettext("You are not allowed to do this."))
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end

end
