defmodule SignDictWeb.Api.CurrentUserController do
  use SignDictWeb, :controller

  def show(conn, _params) do
    render(conn, user: conn.assigns.current_user)
  end
end
