defmodule SignDict.ResetPasswordController do
  use SignDict.Web, :controller

  alias SignDict.Repo
  alias SignDict.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: %User{})
  end

  def create(conn, %{"user" => user}) do
    user = Repo.get_by(User, email: user["email"])
    unless is_nil(user) do
      user_changeset = User.reset_password_changeset(user)

      case Repo.update(user_changeset) do
        {:ok, _updated_auth} ->
          IO.puts "user token added #{Ecto.Changeset.get_field user_changeset, :password_reset_uncrypted}"
          #updated_auth
          #    |> Config.repo.preload([:user])
      #     |> Map.get(:user)
      #     |> Mailer.send_password_reset_email(password_reset_token)
# _ -> nil
      end

    end
    send_redirect_and_flash(conn)
  end

  def edit(conn, params)
  def edit(conn, %{"email" => email, "password_reset_token" => password_reset_token}) do
    render(conn, "edit.html", password_reset_token: password_reset_token, email: email)
  end
  def edit(conn, _params) do
    conn
    |> put_flash(:error, "Invalid password reset link. Please try again.")
    |> redirect(to: "/")
  end

  defp send_redirect_and_flash(conn) do
    conn
    |> put_flash(:info, "You'll receive an email with instructions about how to reset your password in a few minutes.")
    |> redirect(to: "/")
  end
end
