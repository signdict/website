defmodule SignDict.GuardianErrorHandler do
  @moduledoc """
  """
  use SignDict.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, gettext("Authentication required"))
    |> redirect(to: session_path(conn, :new))
  end
end
