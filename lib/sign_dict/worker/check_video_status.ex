defmodule SignDict.Worker.CheckVideoStatus do
  alias SignDict.Repo
  alias SignDict.Video

  def perform(video_id, video_service \\ SignDict.Transcoder.JwPlayer, exq \\ Exq) do
    video = Repo.get(SignDict.Video, video_id)
    status = video_service.check_status(video)

    cond do
      status == :transcoding ->
        exq.enqueue_in(Exq, "default", 60, SignDict.Worker.CheckVideoStatus, [video_id])
        :transcoding
      status == :done ->
        Video.wait_for_review(video)
        :done
      true ->
        {:error, :unknown_status}
    end
  end
end
