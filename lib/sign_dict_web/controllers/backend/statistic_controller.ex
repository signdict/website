defmodule SignDictWeb.Backend.StatisticController do
  use SignDictWeb, :controller
  

  def index(conn = %{assigns: %{current_user: current_user}}, _params) do
    if Canada.Can.can?(current_user, "statistic", %SignDict.Entry{}) do
      render(conn, "index.html")
    else
      conn
      |> put_flash(:info, gettext("You cannot view this page."))
      |> redirect(to: Router.Helpers.backend_dashboard_path(conn, :index))
    end
  end
end
