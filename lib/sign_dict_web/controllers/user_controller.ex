defmodule SignDictWeb.UserController do
  @moduledoc """
  """
  use SignDictWeb, :controller

  alias SignDict.Services.OpenGraph
  alias SignDict.User
  alias SignDict.Video

  plug :load_and_authorize_resource, model: User

  def new(conn, _params) do
    render(conn, "new.html",
      changeset: User.register_changeset(%User{}),
      title: gettext("Register")
    )
  end

  def create(conn, %{"user" => user_params}) do
    do_create(conn, user_params)
  end

  defp do_create(conn, user_params) do
    result =
      %User{}
      |> User.register_changeset(user_params)
      |> Repo.insert()

    case result do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("Your account was created. You can now sign in."))
        |> redirect(to: "/")

      {:error, changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          title: gettext("Register")
        )
    end
  end

  def show(conn, params) do
    user = conn.assigns.user

    render(conn, "show.html",
      user: user,
      searchbar: true,
      videos: load_videos(conn.host, user, params),
      ogtags: OpenGraph.to_metadata(conn.assigns.user),
      title: gettext("User %{user}", user: conn.assigns.user.name)
    )
  end

  def edit(conn, _params) do
    user = conn.assigns.user
    changeset = User.changeset(user)

    render(conn, "edit.html",
      user: user,
      changeset: changeset,
      user: user,
      title: gettext("Edit profile")
    )
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns.user
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Updated successfully."))
        |> redirect(to: Router.Helpers.user_path(conn, :show, user))

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  defp load_videos(domain, user, params) do
    query =
      from v in Video,
        join: e in assoc(v, :entry),
        join: domain in assoc(e, :domains),
        where: v.state == ^"published" and v.user_id == ^user.id and domain.domain == ^domain,
        order_by: e.text,
        preload: :entry

    Repo.paginate(query, params)
  end
end
