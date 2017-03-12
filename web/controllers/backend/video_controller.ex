defmodule SignDict.Backend.VideoController do
  use SignDict.Web, :controller
  alias SignDict.Video

  plug :load_and_authorize_resource, model: Video

  def index(conn, _params) do
    videos = Repo.all(Video)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Video.changeset(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    changeset = Video.changeset(%Video{}, video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: backend_video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    render(conn, "show.html", video: conn.assigns.video)
  end

  def edit(conn, _params) do
    video = conn.assigns.video
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "video" => video_params}) do
    video = conn.assigns.video
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: backend_video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(conn.assigns.video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: backend_video_path(conn, :index))
  end
end
