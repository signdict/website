defmodule SignDictWeb.Backend.UserController do
  use SignDictWeb, :controller

  alias SignDict.User
  alias SignDict.Video

  plug :load_and_authorize_resource, model: User, except: :index

  def index(conn, params) do
    users = load_user_list(conn, params)
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
        |> redirect(to: Router.Helpers.backend_user_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params) do
    user = conn.assigns.user |> Repo.preload(videos: :entry)

    videos =
      Video
      |> where([video], video.user_id == ^user.id)
      |> preload(:entry)
      |> Repo.paginate(params)

    render(conn, "show.html", user: user, videos: videos)
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
        |> redirect(to: Router.Helpers.backend_user_path(conn, :show, user))

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: Router.Helpers.backend_user_path(conn, :index))
  end

  defp load_user_list(conn, params) do
    if Canada.Can.can?(conn.assigns.current_user, :show, %User{}) do
      User |> order_by(:id) |> Repo.paginate(params)
    else
      %Scrivener.Page{
        entries: [],
        page_number: 1,
        page_size: 25,
        total_entries: 0,
        total_pages: 1
      }
    end
  end
end
