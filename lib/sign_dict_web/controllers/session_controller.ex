defmodule SignDictWeb.SessionController do
  @moduledoc """
  """
  use SignDictWeb, :controller

  alias SignDict.Guardian.Plug

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => "", "password" => ""}}) do
    conn
    |> put_flash(:error, gettext("Please fill in an email address and password"))
    |> render("new.html", title: gettext("Login"))
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case SignDict.Services.CredentialVerifier.verify(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Successfully signed in"))
        |> Plug.sign_in(user)
        |> redirect(to: Router.Helpers.page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, gettext("Invalid email address or password"))
        |> render("new.html", title: gettext("Login"))
    end
  end

  def delete(conn, _params) do
    conn
    |> Plug.sign_out()
    |> put_flash(:info, gettext("Successfully signed out"))
    |> redirect(to: "/")
  end
end
