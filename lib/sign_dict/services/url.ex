defmodule SignDict.Services.Url do
  alias SignDict.Entry
  alias SignDict.Video

  def base_url_from_conn(%Plug.Conn{scheme: scheme, host: host, port: port}) do
    protocol =
      if scheme == :http do
        "http"
      else
        "https"
      end

    host_port =
      if port != 80 && port != 443 do
        ":#{port}"
      else
        ""
      end

    "#{protocol}://#{host}#{host_port}"
  end

  def for_entry(nil, _domain), do: nil

  def for_entry(%Entry{videos: videos} = entry, domain) when is_list(videos) do
    videos_with_url =
      videos
      |> Enum.map(fn video ->
        video |> Map.merge(%{url: video_url(domain, entry, video)})
      end)

    entry |> Map.merge(%{url: entry_url(domain, entry), videos: videos_with_url})
  end

  def for_entry(entry = %Entry{}, domain) do
    entry |> Map.merge(%{url: entry_url(domain, entry)})
  end

  defp host(domain) do
    endpoint = Application.get_env(:sign_dict, SignDictWeb.Endpoint)
    "https://#{domain || endpoint[:url][:host]}"
  end

  defp video_url(domain, entry = %Entry{}, video = %Video{}) do
    "#{host(domain)}/entry/#{entry.id}/video/#{video.id}"
  end

  defp entry_url(domain, entry = %Entry{}) do
    "#{host(domain)}/entry/#{entry.id}"
  end
end
