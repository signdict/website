defmodule SignDict.Backend.UserController do
  use SignDict.Web, :controller
  alias SignDict.User

  plug :load_and_authorize_resource, model: User

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.admin_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.admin_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("User created successfully."))
        |> redirect(to: backend_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    render(conn, "show.html", user: conn.assigns.user)
  end

  def edit(conn, _params) do
    user = conn.assigns.user
    changeset = User.admin_changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns.user
    changeset = User.admin_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: backend_user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: backend_user_path(conn, :index))
  end
end
