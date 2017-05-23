defmodule SignDict.EmailConfirmationController do
  use SignDict.Web, :controller

  alias Guardian.Plug
  alias SignDict.Repo
  alias SignDict.User

  def update(conn, params = %{"email" => email, "confirmation_token" => token}) do
    user = Repo.get_by(User, unconfirmed_email: email)
    do_update(conn, user, token, params["change"] == "true")
  end
  def update(conn, _params) do
    do_update(conn, nil, nil, false)
  end

  defp do_update(conn, user, _token, _change) when is_nil(user) do
    conn
    |> put_flash(:error, gettext("Invalid confirmation link."))
    |> redirect(to: "/")
  end
  defp do_update(conn, user, token, change) do
    changeset = User.confirm_email_changeset(user,
                  %{confirmation_token_unencrypted: token})
    case Repo.update(changeset) do
      {:ok, _user_changeset} ->
        conn
        |> Plug.sign_in(user)
        |> redirect_success(change)
      {:error, _user_changeset} ->
        conn
        |> put_flash(:error, gettext("Unable to confirm your email address."))
        |> redirect(to: "/")
    end
  end

  defp redirect_success(conn, true) do
    conn
    |> put_flash(:info, gettext("Your new email address is now confirmed."))
    |> redirect(to: "/")
  end
  defp redirect_success(conn, false) do
    conn
    |> redirect(to: page_path(conn, :welcome))
  end

end
