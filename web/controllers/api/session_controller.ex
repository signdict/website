defmodule SignDict.Api.SessionController do
  use SignDict.Web, :controller

  alias Guardian.Plug

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
