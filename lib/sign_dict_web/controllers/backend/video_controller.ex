defmodule SignDictWeb.Backend.VideoController do
  use SignDictWeb, :controller

  alias SignDict.Entry
  alias SignDict.Video

  plug :load_and_authorize_resource, model: Video,
    preload: [:entry, :user], except: :index

  def index(conn, params) do
    videos = Video
             |> order_by(:id)
             |> preload(:entry)
             |> Repo.paginate(params)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, %{"entry_id" => entry_id}) do
    changeset = Video.changeset(%Video{})
    render(conn, "new.html", changeset: changeset, entry_id: entry_id)
  end

  def create(conn, %{"entry_id" => entry_id, "video" => video_params}) do
    changeset = Video.changeset(%Video{},
                                Map.merge(video_params,
                                          %{"entry_id" => entry_id,
                                            "user_id" => conn.assigns.current_user.id
                                          }))

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: backend_entry_path(conn, :show, entry_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, entry_id: entry_id)
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

  def update(conn, %{"entry_id" => entry_id, "id" => _id, "video" => video_params}) do
    video = conn.assigns.video
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        Entry.update_current_video(Repo.get(SignDict.Entry, video.entry_id))
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: backend_entry_video_path(conn, :show,
                                                 video.entry_id, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset, entry_id: entry_id)
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
