defmodule SignDict.Importer.Wps.SignImporter do
  import Ecto.Query

  alias SignDict.Repo
  alias SignDict.Video
  alias SignDict.Importer.ImporterConfig
  alias SignDict.Importer.Wps.UrlExtractor

  @default_start_time "2016-01-01T00:30:30+00:00"

  def import_json() do
    current_time = Timex.now()
    config = find_or_create_config()
    json = get_json(config)

    videos =
      Enum.map(json, fn json_entry ->
        video = find_video(json_entry)

        if video do
          update_video(video, json_entry)
        end
      end)
      |> Enum.filter(fn item -> item != nil end)

    touch_last_request_time(config, current_time)

    videos
  end

  defp get_json(config) do
    with {:ok, res} <-
           HTTPoison.get(
             add_time_to_url(Application.get_env(:sign_dict, :wps_sign_importer)[:url], config),
             [Accept: "text/json", "User-Agent": "Mozilla/5.0 +signdict.org"],
             follow_redirect: true
           ) do
      if String.length(res.body) > 0 do
        Poison.decode!(res.body)
      else
        []
      end
    end
  end

  defp add_time_to_url(url, config) do
    time = get_time_from(config)
    uri = URI.parse(url)

    query =
      (uri.query || "")
      |> URI.decode_query()
      |> Map.put("lastRequestedDate", Timex.format!(time, "%F %H:%M:%S", :strftime))
      |> URI.encode_query()

    Map.put(uri, :query, query) |> to_string
  end

  defp get_time_from(config) do
    if config.configuration["last_requested"] do
      Timex.parse!(config.configuration["last_requested"], "{ISO:Extended:Z}")
    else
      Timex.parse!(@default_start_time, "{ISO:Extended}")
    end
  end

  defp find_or_create_config() do
    ImporterConfig.for("WPS-Sign") || Repo.insert!(%ImporterConfig{name: "WPS-Sign"})
  end

  defp touch_last_request_time(config, current_time) do
    updated_config =
      (config.configuration || %{})
      |> Map.put("last_requested", Timex.format!(current_time, "{ISO:Extended:Z}"))

    config
    |> ImporterConfig.changeset(%{configuration: updated_config})
    |> Repo.update()
  end

  defp fetch_sign_writing(%{"gebaerdenSchriftUrl" => image_url}) do
    url = UrlExtractor.extract(image_url)

    if url != nil && String.length(url) > 0 do
      result = HTTPoison.get!(url)

      if result.status_code == 200 do
        {:ok, filename} = Briefly.create()
        File.write!(filename, result.body)
        filename
      end
    end
  end

  defp fetch_sign_writing(_) do
    nil
  end

  defp find_video(%{"videoUrl" => video_url}) do
    url = UrlExtractor.extract(video_url)
    Repo.one(from v in Video, where: v.video_url == ^url)
  end

  defp find_video(_) do
    nil
  end

  defp update_video(video, json) do
    sign_writing = fetch_sign_writing(json)

    if sign_writing do
      save_video(video, json, sign_writing)
    end
  end

  defp save_video(video, json_entry, sign_writing) do
    video
    |> Video.changeset_uploader(%{
      metadata: Map.merge(video.metadata, %{"source_sign_json" => json_entry}),
      sign_writing: %Plug.Upload{
        content_type: "image/png",
        filename: "file.png",
        path: sign_writing
      }
    })
    |> Repo.update!()
  end
end
