defmodule SignDict.Api.UploadController do
  use SignDict.Web, :controller

  alias SignDict.Video

  def create(conn, %{"entry_id" => entry_id, "video" => fileupload}) do
    result = conn
             |> upload_video(entry_id, fileupload)
             |> Repo.insert()

    case result do
      {:ok, video} ->
        render(conn, video: video)
      {:error, _changeset} ->
        conn
        |> put_status(404)
        |> render(error: "Could not store video")
    end
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

  defp upload_video(conn, entry_id, fileupload) do
    %Video{}
    |> Video.changeset_uploader(%{
      entry_id: entry_id,
      license: "by/4.0",
      user_id: get_user_id(conn)
    })

    #video = Repo.insert!(%Video{
      #copyright: "#{json["author"]} - #{json["source"]}",
      #license: json["license"],
      #original_href: json["word_link"],
      #metadata: %{
        #source_json: json,
        #source_mp4:  filename
      #},
      #user: user,
      #entry: entry,
      #state: "uploaded"
    #})
    #exq.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video.id])
  end

end
