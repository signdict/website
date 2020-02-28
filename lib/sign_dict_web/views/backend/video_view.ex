defmodule SignDictWeb.Backend.VideoView do
  use SignDictWeb, :view
  import Scrivener.HTML

  def format_metadata(video) do
    {:ok, json} = Poison.encode(video.metadata, pretty: true)
    json
  end
end
