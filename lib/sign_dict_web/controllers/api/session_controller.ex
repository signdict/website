defmodule SignDictWeb.Api.SessionController do
  use SignDictWeb, :controller

  alias SignDict.Guardian.Plug

  def create(conn, %{"email" => email, "password" => password}) do
    case SignDict.Services.CredentialVerifier.verify(email, password) do
      {:ok, user} ->
        conn
        |> Plug.sign_in(user)
        |> assign(:current_user, user)
        |> render(user: user)
      {:error, _reason} ->
        conn
        |> put_status(401)
        |> render(error: "Email and/or password invalid")
    end
  end

end
