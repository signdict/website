defmodule SignDict.Services.Url do
  alias SignDict.Entry
  alias SignDict.Video

  def for_entry(nil), do: nil

  def for_entry(%Entry{videos: videos} = entry) when is_list(videos) do
    videos_with_url =
      videos
      |> Enum.map(fn video ->
        video |> Map.merge(%{url: video_url(entry, video)})
      end)

    entry |> Map.merge(%{url: entry |> entry_url(), videos: videos_with_url})
  end

  def for_entry(entry = %Entry{}) do
    entry |> Map.merge(%{url: entry |> entry_url()})
  end

  defp host do
    "https://#{Application.get_env(:sign_dict, SignDict.Endpoint)[:url][:host]}"
  end

  defp video_url(entry = %Entry{}, video = %Video{}) do
    "#{host()}/entry/#{entry.id}/video/#{video.id}"
  end

  defp entry_url(entry = %Entry{}) do
    "#{host()}/entry/#{entry.id}"
  end
end
