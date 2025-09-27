defmodule SignDictWeb.VoteController do
  use SignDictWeb, :controller
  

  plug Guardian.Plug.EnsureAuthenticated, error_handler: SignDictWeb.GuardianErrorHandler

  alias SignDict.Vote
  alias SignDict.Video

  def create(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id) |> Repo.preload(:entry)

    case Vote.vote_video(conn.assigns.current_user, video) do
      {:ok, _vote} ->
        conn
        |> put_flash(:info, gettext("Thanks for voting!"))
        |> redirect(to: Router.Helpers.entry_video_path(conn, :show, video.entry, video))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Sadly your voting failed."))
        |> redirect(to: Router.Helpers.entry_video_path(conn, :show, video.entry, video))
    end
  end

  def delete(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id) |> Repo.preload(:entry)

    Vote.delete_vote(conn.assigns.current_user, video)

    conn
    |> put_flash(:info, gettext("You vote was reverted successfully"))
    |> redirect(to: Router.Helpers.entry_video_path(conn, :show, video.entry, video))
  end
end
