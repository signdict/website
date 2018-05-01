defmodule SignDictWeb.ResetPasswordController do
  use SignDictWeb, :controller

  alias SignDict.Repo
  alias SignDict.User
  alias SignDictWeb.Email
  alias SignDictWeb.Mailer

  def new(conn, _params) do
    render(conn, "new.html", changeset: %User{}, title: gettext("Reset password"))
  end

  def create(conn, %{"user" => user}) do
    user = Repo.get_by(User, email: user["email"])
    send_password_reset_link_to_user(user)
    conn
    |> put_flash(:info, gettext("You'll receive an email with instructions about how to reset your password in a few minutes."))
    |> redirect(to: "/")
  end

  def edit(conn, params)
  def edit(conn, %{"email" => email, "password_reset_token" => password_reset_token}) do
    render(conn, "edit.html", password_reset_unencrypted: password_reset_token,
                              email: email, title: gettext("Reset password"))
  end
  def edit(conn, _params) do
    conn
    |> put_flash(:error, gettext("Invalid password reset link. Please try again."))
    |> redirect(to: "/")
  end

  def update(conn, params = %{"user" => %{"email" => email, "password_reset_unencrypted" => password_reset_token}}) do
    user      = Repo.get_by(User, email: email)
    changeset = User.reset_password_changeset(user, params["user"])
    case Repo.update(changeset) do
       {:ok, _user_changeset} ->
         conn
         |> put_flash(:info, gettext("Password successfully changed"))
         |> redirect(to: "/")
       {:error, _user_changeset} ->
         conn
         |> put_flash(:error, gettext("Unable to change your password"))
         |> render("edit.html", password_reset_unencrypted: password_reset_token,
                                email: email)
    end
  end
  def update(conn, _params) do
    conn
    |> put_flash(:error, gettext("Invalid password reset link. Please try again."))
    |> redirect(to: "/")
  end

  defp send_password_reset_link_to_user(nil), do: nil
  defp send_password_reset_link_to_user(user) do
    user_changeset = User.create_reset_password_changeset(user)
    {:ok, user} = Repo.update(user_changeset)
    user
    |> Email.password_reset
    |> Mailer.deliver_later
  end

end
