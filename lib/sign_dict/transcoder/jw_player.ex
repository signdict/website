defmodule SignDict.Transcoder.JwPlayer do
  @behaviour SignDict.Transcoder.API

  def upload_video(video) do
    {:ok, video}
  end

  def check_status(_video) do
    # Possible return values are :transcoding, :done, :error
    :transcoding
  end

end
