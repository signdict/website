defmodule SignDict.UserController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias SignDict.User
  alias Guardian.Plug

  plug :load_and_authorize_resource, model: User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.register_changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    result = %User{}
             |> User.register_changeset(user_params)
             |> Repo.insert()

    case result do
      {:ok, user} ->
        conn
        |> Plug.sign_in(user)
        |> redirect(to: page_path(conn, :welcome))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, _params) do
    video_count = SignDict.Video
                  |> where(user_id: ^conn.assigns.user.id)
                  |> Repo.aggregate(:count, :id)
    render(conn, "show.html",
      user: conn.assigns.user,
      searchbar: true,
      video_count: video_count
    )
  end

  def edit(conn, _params) do
    user = conn.assigns.user
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset, user: user)
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns.user
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Updated successfully."))
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end
end
