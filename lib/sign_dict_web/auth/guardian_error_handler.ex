defmodule SignDictWeb.GuardianErrorHandler do
  @moduledoc """
  """
  use SignDictWeb, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, gettext("Authentication required"))
    |> redirect(to: session_path(conn, :new))
    |> halt
  end

  def handle_unauthorized(conn) do
    conn
    |> put_flash(:error, gettext("Sadly you are not allowed to do this"))
    |> redirect(to: "/")
    |> halt
  end

  def handle_resource_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(SignDictWeb.ErrorView, "404.html")
    |> halt
  end

end
