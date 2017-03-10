defmodule SignDict.Plug.AllowedForBackend do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  import SignDict.Gettext, only: [gettext: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    redirect_if_not_allowed(conn, conn.assigns.current_user)
  end

  defp redirect_if_not_allowed(conn, current_user)
  defp redirect_if_not_allowed(conn, %{role: "admin"}), do: conn
  defp redirect_if_not_allowed(conn, _current_user) do
    conn
    |> put_flash(:error, gettext("You are not allowed to do this."))
    |> put_status(:unauthorized)
    |> redirect(to: "/")
    |> halt()
  end
end
