defmodule SignDict.VoteController do
  use SignDict.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: SignDict.GuardianErrorHandler

  alias SignDict.Vote
  alias SignDict.Video

  def create(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id)
    changeset = Vote.changeset(%Vote{user_id: conn.assigns.current_user.id, video_id: video.id})

    case Repo.insert(changeset) do
      {:ok, _vote} ->
        conn
          |> put_flash(:info, "You voted successfully.")
          |> redirect(to: entry_path(conn, :show, video.entry_id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Your vote failed.")
          |> redirect(to: entry_path(conn, :show, video.entry_id))
    end
  end

  def delete(conn, %{"video_id" => video_id}) do
    video = Video |> Repo.get!(video_id)
    vote = Vote |> Repo.get_by(%{video_id: video.id, user_id: conn.assigns.current_user.id})

    unless vote do
      conn
        |> put_flash(:error, "Your vote could not be found.")
        |> redirect(to: entry_path(conn, :show, video.entry_id))
    else
      case Repo.delete(vote) do
        {:ok, _vote} ->
          conn
            |> put_flash(:info, "You vote was reverted successfully")
            |> redirect(to: entry_path(conn, :show, video.entry_id))
        {:error, changeset} ->
          conn
            |> put_flash(:error, "Your vote deletion failed.")
            |> redirect(to: entry_path(conn, :show, video.entry_id))
      end
    end
  end
end
