defmodule SignDictWeb.Api.RegisterController do
  use SignDictWeb, :controller

  alias SignDict.User

  def create(conn, %{"user" => user_params}) do
    result =
      %User{}
      |> User.register_changeset(user_params)
      |> Repo.insert()

    case result do
      {:ok, user} ->
        conn
        |> put_session(:registered_user_id, user.id)
        |> render(user: user)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(errors: changeset.errors)
    end
  end
end
