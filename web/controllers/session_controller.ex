defmodule SignDict.SessionController do
  @moduledoc """
  """
  use SignDict.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias SignDict.User
  alias Guardian.Plug

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => "", "password" => ""}}) do
    conn
    |> put_flash(:error, gettext("Please fill in an email address and password"))
    |> render("new.html", title: gettext("Login"))
  end

  def create(conn, %{"session" => %{"email" => email,
                                    "password" => password}}) do
    case verify_credentials(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Successfully signed in"))
        |> Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))
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

  defp verify_credentials(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- find_by_email(email),
      do: verify_password(password, user)
  end

  defp find_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, gettext("Invalid email address or password")}
      user ->
        {:ok, user}
    end

  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if checkpw(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
