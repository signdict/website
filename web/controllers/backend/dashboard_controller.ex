defmodule SignDict.Backend.DashboardController do
  use SignDict.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
