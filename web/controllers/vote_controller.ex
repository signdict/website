defmodule SignDict.VoteController do
  use SignDict.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: SignDict.GuardianErrorHandler

  alias SignDict.Entry
  alias SignDict.Vote
  alias SignDict.Video

  def create(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id) |> Repo.preload(:entry)

    case Vote.vote_video(conn.assigns.current_user, video) do
      {:ok, _vote} ->
        conn
          |> put_flash(:info, gettext("Thanks for voting!"))
          |> redirect(to: entry_video_path(conn, :show, video.entry, video))
      {:error, _changeset} ->
        conn
          |> put_flash(:error, gettext("Sadly your voting failed."))
          |> redirect(to: entry_video_path(conn, :show, video.entry, video))
    end
  end

  def delete(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id) |> Repo.preload(:entry)
    vote = Vote |> Repo.get_by(%{video_id: video.id,
                                 user_id: conn.assigns.current_user.id})
    do_delete(conn, video, vote)
  end

  defp do_delete(conn, video, vote)
  defp do_delete(conn, video, vote) when is_nil(vote) do
    conn
    |> put_flash(:error, gettext("Sadly your vote could not be found."))
    |> redirect(to: entry_video_path(conn, :show, video.entry, video))
  end
  defp do_delete(conn, video, vote) do
    case Repo.delete(vote) do
      {:ok, _vote} ->
        Entry.update_current_video(video.entry)
        conn
          |> put_flash(:info, gettext("You vote was reverted successfully"))
          |> redirect(to: entry_video_path(conn, :show, video.entry, video))
      {:error, _changeset} ->
        conn
          |> put_flash(:error, gettext("Sadly your vote deletion failed."))
          |> redirect(to: entry_path(conn, :show, video.entry))
    end
  end
end
