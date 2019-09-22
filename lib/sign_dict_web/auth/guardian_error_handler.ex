defmodule SignDictWeb.GuardianErrorHandler do
  @moduledoc """
  """
  use SignDictWeb, :controller

  alias SignDict.Guardian

  def auth_error(conn, {:invalid_token, _reason}, _opts) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/")
    |> halt
  end

  def auth_error(conn, {:unauthorized, _reason}, _opts) do
    conn
    |> put_flash(:error, gettext("Sadly you are not allowed to do this"))
    |> redirect(to: "/")
    |> halt
  end

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    conn
    |> put_flash(:error, gettext("Authentication required"))
    |> redirect(to: session_path(conn, :new))
    |> halt
  end

  def auth_error(conn, {:already_authenticated, _reason}, _opts) do
    conn
    |> put_flash(:error, gettext("Already authenticated"))
    |> redirect(to: session_path(conn, :new))
    |> halt
  end

  def auth_error(conn, {:no_resource_found, _reason}, _opts) do
    conn
    |> put_status(:not_found)
    |> put_view(SignDictWeb.ErrorView)
    |> render("404.html")
    |> halt
  end

  def handle_unauthorized(conn) do
    auth_error(conn, {:unauthorized, nil}, nil)
  end

  def handle_resource_not_found(conn) do
    auth_error(conn, {:no_resource_found, nil}, nil)
  end
end
