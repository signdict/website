defmodule SignDict.Transcoder.API do
  alias SignDict.Video

  @callback upload_video(arg :: %Video{}) :: any
  @callback check_status(arg :: %Video{}) :: any
end
