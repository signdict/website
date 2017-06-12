defmodule SignDict.Api.RegisterController do
  use SignDict.Web, :controller

  alias SignDict.Email
  alias SignDict.Mailer
  alias SignDict.User

  def create(conn, %{"user" => user_params}) do
    result = %User{}
             |> User.register_changeset(user_params)
             |> Repo.insert()

    case result do
      {:ok, user} ->
        send_user_mails(user)
        conn
        |> put_session(:registered_user_id, user.id)
        |> render(user: user)
      {:error, changeset} ->
        render conn, errors: changeset.errors
    end
  end

  defp send_user_mails(user) do
    if user.want_newsletter, do: User.subscribe_to_newsletter(user)

    user
    |> Email.confirm_email
    |> Mailer.deliver_later
  end

end
