defmodule SignDictWeb.Api.UploadController do
  use SignDictWeb, :controller

  alias SignDict.Video
  alias SignDict.Services.VideoImporter

  def create(conn, %{"entry_id" => entry_id, "video" => fileupload,
                     "end_time" => end_time, "start_time" => start_time}) do
    result = conn
             |> upload_video(entry_id, fileupload, start_time, end_time)
             |> Repo.insert()
    case result do
      {:ok, video} ->
        queue = Application.get_env(:sign_dict, :queue)[:library]
        queue.enqueue(Exq, "transcoder", SignDict.Worker.PrepareVideo, [video.id])
        render(conn, video: video)
      {:error, _changeset} ->
        conn
        |> put_status(404)
        |> render(error: "Could not store video")
    end
  end

  defp upload_video(conn, entry_id, fileupload, start_time, end_time) do
    filename = VideoImporter.store_file(fileupload.path, fileupload.filename)
    %Video{}
    |> Video.changeset_uploader(%{
      entry_id: entry_id,
      license: "by/4.0",
      user_id: get_user_id(conn),
      metadata: %{
        source_webm: filename,
        video_start_time: start_time,
        video_end_time: end_time
      },
      state: "uploaded"
    })
  end

  defp get_user_id(conn) do
    cond do
      conn.assigns.current_user != nil ->
        conn.assigns.current_user.id
      conn.assigns.registered_user_id != nil ->
        conn.assigns.registered_user_id
      true ->
        get_session(conn, :registered_user_id)
    end
  end

end
