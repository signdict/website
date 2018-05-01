defmodule SignDictWeb.Backend.DashboardController do
  use SignDictWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
