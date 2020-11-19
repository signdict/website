defmodule SignDictWeb.Backend.DomainControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Domain

  @valid_attrs %{
    domain: "signdict"
  }
  @invalid_attrs %{
    domain: ""
  }

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get(conn, backend_domain_path(conn, :index))
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:user))
      |> get(backend_domain_path(conn, :index))

    assert redirected_to(conn, 302) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_domain_path(conn, :index))

    assert html_response(conn, 200) =~ "Listing domains"
  end

  test "renders form for new resources", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_domain_path(conn, :new))

    assert html_response(conn, 200) =~ "New domain"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(backend_domain_path(conn, :create), domain: @valid_attrs)

    assert redirected_to(conn) == backend_domain_path(conn, :index)
    assert Repo.get_by(Domain, domain: "signdict")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> post(backend_domain_path(conn, :create), domain: @invalid_attrs)

    assert html_response(conn, 200) =~ "New domain"
  end

  test "shows chosen resource", %{conn: conn} do
    domain = insert(:domain)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_domain_path(conn, :show, domain))

    assert html_response(conn, 200) =~ domain.domain
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_domain_path(conn, :show, 123_123_123))

    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    domain = Repo.insert!(%Domain{})

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> get(backend_domain_path(conn, :edit, domain))

    assert html_response(conn, 200) =~ "Edit domain"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    domain = insert(:domain)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(backend_domain_path(conn, :update, domain), domain: @valid_attrs)

    assert redirected_to(conn) ==
             backend_domain_path(conn, :show, Repo.get(SignDict.Domain, domain.id))

    assert Repo.get_by(Domain, domain: "signdict")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    domain = insert(:domain)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> put(backend_domain_path(conn, :update, domain), domain: @invalid_attrs)

    assert html_response(conn, 200) =~ "Edit domain"
  end

  test "deletes chosen resource", %{conn: conn} do
    domain = insert(:domain)

    conn =
      conn
      |> guardian_login(insert(:admin_user))
      |> delete(backend_domain_path(conn, :delete, domain))

    assert redirected_to(conn) == backend_domain_path(conn, :index)
    refute Repo.get(Domain, domain.id)
  end
end
