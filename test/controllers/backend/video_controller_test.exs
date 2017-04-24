defmodule SignDict.Backend.VideoControllerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.Video
  @valid_attrs %{
    copyright: "some content", license: "some content",
    original_href: "some content", state: "uploaded",
    thumbnail_url: "http://example.com/video.jpg",
    video_url: "http://example.com/video.mp4"
  }
  @invalid_attrs %{}

  test "it redirects when no user logged in", %{conn: conn} do
    conn = get conn, backend_video_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "it redirects when non admin user logged in", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:user))
           |> get(backend_video_path(conn, :index))
    assert redirected_to(conn, 401) == "/"
  end

  test "lists all entries on index", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_video_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing videos"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_video_path(conn, :new, entry().id))
    assert html_response(conn, 200) =~ "New video"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    current_entry = entry()
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_entry_video_path(conn, :create, current_entry.id), video: @valid_attrs)
    assert redirected_to(conn) == backend_entry_path(conn, :show, current_entry.id)
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> post(backend_entry_video_path(conn, :create, entry().id), video: @invalid_attrs)
    assert html_response(conn, 200) =~ "New video"
  end

  test "shows chosen resource", %{conn: conn} do
    video = insert :video_with_entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_video_path(conn, :show, video.entry_id, video))
    assert html_response(conn, 200) =~ "Video"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_video_path(conn, :show, entry().id, -1))
    assert conn.status == 404
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    video = insert :video_with_entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> get(backend_entry_video_path(conn, :edit, video.entry_id, video))
    assert html_response(conn, 200) =~ "Edit video"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    video = insert :video_with_entry
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_entry_video_path(conn, :update, video.entry_id, video), video: @valid_attrs)
    assert redirected_to(conn) == backend_entry_video_path(conn, :show, video.entry.id, video)
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    video = Repo.insert! %Video{entry_id: entry().id}
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> put(backend_entry_video_path(conn, :update, video.entry_id, video),
                  video: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit video"
  end

  test "deletes chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{entry_id: entry().id}
    conn = conn
           |> guardian_login(insert(:admin_user))
           |> delete(backend_entry_video_path(conn, :delete, video.entry_id, video))
    assert redirected_to(conn) == backend_video_path(conn, :index)
    refute Repo.get(Video, video.id)
  end

  def entry do
    insert :entry
  end
end
