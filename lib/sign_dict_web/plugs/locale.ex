defmodule SignDictWeb.Plug.Locale do
  @behaviour Plug
  import Plug.Conn

  alias SignDict.Repo
  alias SignDict.User

  def init(_opts), do: nil

  def call(conn, _opts) do
    case conn |> fetch_locale() |> filter_allowed_locale() do
      nil -> conn
      locale -> update_user_locale(conn, locale)
    end
  end

  defp filter_allowed_locale(locale) do
    if Enum.member?(["de", "en"], locale) do
      locale
    else
      nil
    end
  end

  defp fetch_locale(conn) do
    conn.params["locale"] || get_user_locale(conn) || get_session(conn, :locale)
  end

  defp get_user_locale(conn) do
    accept_language = Plug.Conn.get_req_header(conn, "accept-language") |> Plug.Conn.get_accept_language()

    case accept_language do
      [locale | _rest] ->
        locale
      [] when conn.assigns[:current_user] ->
        conn.assigns[:current_user].locale
      _ ->
        nil
    end
  end

  defp update_user_locale(conn, locale) do
    if conn.assigns[:current_user], do: store_locale(conn.assigns.current_user, locale)
    Gettext.put_locale(SignDictWeb.Gettext, locale)
    conn |> put_session(:locale, locale)
  end

  defp store_locale(user, locale) do
    if user.locale != locale do
      user
      |> User.changeset(%{locale: locale})
      |> Repo.update()
    end
  end
end
