defmodule SignDict.Plug.LocaleTest do
  use SignDict.ConnCase

  alias SignDict.User

  import SignDict.Factory

  test "setting the locale from the param", %{conn: conn} do
    conn = conn |> get("/", %{"locale" => "de"})
    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
  end

  test "setting the locale from the value stored in the session", %{conn: conn} do
    conn =
      conn
      |> get("/", %{"locale" => "de"})
      |> recycle()
      |> get("/")

    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
  end

  test "updates the locale of the user", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> guardian_login(user)
      |> get("/", %{"locale" => "de"})
      |> recycle()
      |> get("/")

    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
    assert Repo.get(User, user.id).locale == "de"
  end

  test "loads the locale from the user", %{conn: conn} do
    user = insert(:user, locale: "de")

    conn =
      conn
      |> guardian_login(user)
      |> get("/")

    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
  end
end
