defmodule SignDict.UserController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  alias Ecto.Changeset
  alias SignDict.Email
  alias SignDict.Mailer
  alias SignDict.Services.OpenGraph
  alias SignDict.User

  plug :load_and_authorize_resource, model: User

  def new(conn, _params) do
    render conn, "new.html",
      changeset: User.register_changeset(%User{}),
      title: gettext("Register")
  end

  def create(conn, %{"user" => user_params}) do
    result = %User{}
             |> User.register_changeset(user_params)
             |> Repo.insert()

    case result do
      {:ok, user} ->
        if user.want_newsletter, do: User.subscribe_to_newsletter(user)
        conn
        |> sent_confirm_email(user)
        |> redirect(to: "/")
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset,
          title: gettext("Register")
    end
  end

  def show(conn, _params) do
    video_count = SignDict.Video
                  |> where(user_id: ^conn.assigns.user.id)
                  |> Repo.aggregate(:count, :id)
    render(conn, "show.html",
      user: conn.assigns.user,
      searchbar: true,
      video_count: video_count,
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
        |> sent_confirm_email_change(user, changeset)
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  defp sent_confirm_email(conn, user) do
    user
    |> Email.confirm_email
    |> Mailer.deliver_later
    conn
    |> put_flash(:info, gettext("Please click on the link in the email we just sent to confirm your account."))
  end

  defp sent_confirm_email_change(conn, user, changeset) do
    if Changeset.fetch_change(changeset, :unconfirmed_email) != :error do
      user
      |> Email.confirm_email_change
      |> Mailer.deliver_later
      conn
      |> put_flash(:info, gettext("Please click on the link in the email we just sent to confirm the change of your email."))
    else
      conn
    end
  end
end
