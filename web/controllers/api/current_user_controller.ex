defmodule SignDict.Api.CurrentUserController do
  use SignDict.Web, :controller

  def show(conn, _params) do
    render conn, user: conn.assigns.current_user
  end

end
