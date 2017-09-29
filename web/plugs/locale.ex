defmodule SignDict.Plug.Locale do
  import Plug.Conn

  alias SignDict.Repo
  alias SignDict.User

  def init(_opts), do: nil

  def call(conn, _opts) do
    case fetch_locale(conn) do
      nil     -> conn
      locale  -> update_user_locale(conn, locale)
    end
  end

  defp fetch_locale(conn) do
    conn.params["locale"] ||
      get_user_locale(conn) ||
      get_session(conn, :locale)
  end

  defp get_user_locale(conn) do
    if conn.assigns[:current_user] do
      conn.assigns[:current_user].locale
    end
  end

  defp update_user_locale(conn, locale) do
    if conn.assigns[:current_user], do: store_locale(conn.assigns.current_user, locale)
    Gettext.put_locale(SignDict.Gettext, locale)
    conn |> put_session(:locale, locale)
  end

  defp store_locale(user, locale) do
    if user.locale != locale do
      user
      |> User.changeset(%{locale: locale})
      |> Repo.update
    end
  end

end
