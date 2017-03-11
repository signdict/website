defmodule SignDict.Backend.UserController do
  use SignDict.Web, :controller
  alias SignDict.User

  plug :load_and_authorize_resource, model: User

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end
end
