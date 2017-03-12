defmodule SignDict.Plug.LocaleTest do
  use SignDict.ConnCase

  test "setting the locale from the param", %{conn: conn} do
    conn = conn |> get("/", %{"locale" => "de"})
    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
  end

  test "setting the locale from the value stored in the session", %{conn: conn} do
    conn = conn
           |> get("/", %{"locale" => "de"})
           |> recycle()
           |> get("/")
    assert Gettext.get_locale(SignDict.Gettext) == "de"
    assert get_session(conn, :locale) == "de"
  end
end
