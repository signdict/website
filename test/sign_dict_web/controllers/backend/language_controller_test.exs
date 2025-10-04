defmodule SignDictWeb.Backend.LanguageControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Language

  @valid_attrs %{
    iso6393: "gsg2",
    long_name: "German Sign Language",
    short_name: "DGS",
    default_locale: "DE"
  }
  @invalid_attrs %{
    iso6393: ""
  }

  test "it redirects when no language logged in", %{conn: conn} do
    conn = get(conn, Helpers.backend_language_path(conn, :index))
    assert redirected_to(conn) == Helpers.session_path(conn, :new)
  end

  test "it redirects when non admin language logged in", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:user))
      |> get(Helpers.backend_language_path(conn, :index))

    assert redirected_to(conn, 302) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_language_path(conn, :index))

    assert html_response(conn, 200) =~ "Listing languages"
  end

  test "renders form for new resources", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_language_path(conn, :new))

    assert html_response(conn, 200) =~ "New language"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(Helpers.backend_language_path(conn, :create),
        language: @valid_attrs
      )

    assert redirected_to(conn) == Helpers.backend_language_path(conn, :index)
    assert Repo.get_by(Language, iso6393: "gsg2")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(Helpers.backend_language_path(conn, :create),
        language: @invalid_attrs
      )

    assert html_response(conn, 200) =~ "New language"
  end

  test "shows chosen resource", %{conn: conn} do
    language = Repo.insert!(%Language{})

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_language_path(conn, :show, language))

    assert html_response(conn, 200) =~ "Language"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_language_path(conn, :show, -1))

    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    language = Repo.insert!(%Language{})

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(Helpers.backend_language_path(conn, :edit, language))

    assert html_response(conn, 200) =~ "Edit language"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    language = insert(:language_dgs)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(Helpers.backend_language_path(conn, :update, language),
        language: @valid_attrs
      )

    assert redirected_to(conn) ==
             Helpers.backend_language_path(conn, :show, language)

    assert Repo.get_by(Language, iso6393: "gsg2")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    language = insert(:language_dgs)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(Helpers.backend_language_path(conn, :update, language),
        language: @invalid_attrs
      )

    assert html_response(conn, 200) =~ "Edit language"
  end

  test "deletes chosen resource", %{conn: conn} do
    language = insert(:language_dgs)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> delete(Helpers.backend_language_path(conn, :delete, language))

    assert redirected_to(conn) == Helpers.backend_language_path(conn, :index)
    refute Repo.get(Language, language.id)
  end
end
