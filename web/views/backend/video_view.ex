defmodule SignDict.Backend.VideoView do
  use SignDict.Web, :view
  import Scrivener.HTML

  def format_metadata(video) do
   {:ok, json} = Poison.encode(video.metadata, pretty: true)
   json
  end
end
