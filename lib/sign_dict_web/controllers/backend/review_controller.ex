defmodule SignDictWeb.Backend.ReviewController do
  use SignDictWeb, :controller

  alias SignDict.Entry
  alias SignDict.Video

  def index(conn, params) do
    videos =
      Video
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
        update_entry(video)

        conn
        |> put_flash(:info, gettext("Video approved"))
        |> redirect(
          to: Router.Helpers.backend_entry_video_path(conn, :show, video.entry_id, video.id)
        )

      {:error, _video} ->
        conn
        |> put_flash(:error, gettext("Video could not be approved"))
        |> redirect(
          to: Router.Helpers.backend_entry_video_path(conn, :show, video.entry_id, video.id)
        )
    end
  end

  def reject_video(conn, %{
        "video_id" => video_id,
        "video" => %{"rejection_reason" => rejection_reason}
      }) do
    changeset =
      Video
      |> Repo.get(video_id)
      |> Video.changeset(%{rejection_reason: rejection_reason})

    case Video.reject(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, gettext("Video rejected"))
        |> redirect(
          to: Router.Helpers.backend_entry_video_path(conn, :show, video.entry_id, video.id)
        )

      {:error, changeset} ->
        video = changeset.data

        conn
        |> put_flash(:error, gettext("Video could not be rejected"))
        |> redirect(
          to: Router.Helpers.backend_entry_video_path(conn, :show, video.entry_id, video.id)
        )
    end
  end

  defp update_entry(video) do
    entry = Repo.get(Entry, video.entry_id)
    Entry.update_current_video(entry)
  end
end
