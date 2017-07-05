defmodule SignDict.Backend.ReviewController do
  use SignDict.Web, :controller

  alias SignDict.Video
  alias SignDict.Email
  alias SignDict.Mailer

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
    case Video.publish(video) do
      {:ok, video} ->
        inform_user_of_approval(video)
        conn
        |> put_flash(:info, gettext("Video approved"))
        |> redirect(to: backend_entry_video_path(conn, :show, video.entry_id, video.id))
      {:error, _video} ->
        conn
        |> put_flash(:error, gettext("Video could not be approved"))
        |> redirect(to: backend_entry_video_path(conn, :show, video.entry_id, video.id))
    end
  end

  def reject_video(conn, %{"video_id" => video_id, "video" => %{"rejection_reason" => rejection_reason}}) do
    changeset = Repo.get_by(Video, id: video_id)
                |> Video.changeset(%{rejection_reason: rejection_reason})
    case Video.reject(changeset) do
      {:ok, video} ->
        inform_user_of_rejection(video)
        conn
        |> put_flash(:info, gettext("Video rejected"))
        |> redirect(to: backend_entry_video_path(conn, :show, video.entry_id, video.id))
      {:error, changeset} ->
        video = changeset.data
        conn
        |> put_flash(:error, gettext("Video could not be rejected"))
        |> redirect(to: backend_entry_video_path(conn, :show, video.entry_id, video.id))
    end
  end

  defp inform_user_of_approval(video) do
    video
    |> Email.video_approved
    |> Mailer.deliver_later
  end

  defp inform_user_of_rejection(video) do
    video
    |> Email.video_rejected
    |> Mailer.deliver_later
  end

end
