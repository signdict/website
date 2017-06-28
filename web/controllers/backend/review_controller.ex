defmodule SignDict.Backend.ReviewController do
  use SignDict.Web, :controller
  alias SignDict.Video

  def index(conn, params) do
    videos = Video
             |> where([c], c.state == "waiting_for_review")
             |> order_by(:updated_at)
             |> preload(:entry)
             |> Repo.paginate(params)
    render(conn, "index.html", videos: videos)
  end

  def approve_video(conn, %{"video_id" => video_id}) do
    video = Repo.get_by(Video, id: video_id)
    conn
    |> put_flash(:info, gettext("Video approved"))
    |> redirect(to: backend_entry_video_path(conn, :show, video.entry_id, video.id))
  end

end
