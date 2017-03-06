defmodule SignDict.Backend.VideoControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Video
  @valid_attrs %{copyright: "some content", license: "some content", original_href: "some content", state: "uploaded", type: "some content"}
  @invalid_attrs %{}

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get conn, backend_video_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing videos"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :new))
    assert html_response(conn, 200) =~ "New video"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> post(backend_video_path(conn, :create), video: @valid_attrs)
    assert redirected_to(conn) == backend_video_path(conn, :index)
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> post(backend_video_path(conn, :create), video: @invalid_attrs)
    assert html_response(conn, 200) =~ "New video"
  end

  test "shows chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :show, video))
    assert html_response(conn, 200) =~ "Show video"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = guardian_login(conn, insert(:user))
    assert_error_sent 404, fn ->
      get(conn, backend_video_path(conn, :show, -1))
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :edit, video))
    assert html_response(conn, 200) =~ "Edit video"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    video = Repo.insert! %Video{}

    conn = conn
           |> guardian_login(insert(:user))
           |> put(backend_video_path(conn, :update, video), video: @valid_attrs)
    assert redirected_to(conn) == backend_video_path(conn, :show, video)
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = conn
           |> guardian_login(insert(:user))
           |> put(backend_video_path(conn, :update, video), video: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit video"
  end

  test "deletes chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = conn
           |> guardian_login(insert(:user))
           |> delete(backend_video_path(conn, :delete, video))
    assert redirected_to(conn) == backend_video_path(conn, :index)
    refute Repo.get(Video, video.id)
  end
end
