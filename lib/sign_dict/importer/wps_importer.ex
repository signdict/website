defmodule SignDict.Importer.WpsImporter do
  import Ecto.Query

  alias SignDict.Domain
  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.Repo
  alias SignDict.Services.VideoImporter
  alias SignDict.User
  alias SignDict.Video
  alias SignDict.Importer.ImporterConfig

  @default_start_time "2016-01-01T00:30:30+00:00"

  def import_json(exq \\ Exq) do
    current_time = Timex.now()
    config = find_or_create_config()
    json = get_json(config)
    user = find_or_create_user_for("WPS")

    videos =
      Enum.map(json, fn json_entry ->
        entry = find_or_create_entry_for(json_entry)
        insert_or_update_video(entry, user, json_entry, exq)
      end)

    touch_last_request_time(config, current_time)

    videos
  end

  defp get_json(config) do
    with {:ok, res} <-
           HTTPoison.get(
             add_time_to_url(Application.get_env(:sign_dict, :wps_importer)[:url], config),
             [Accept: "text/json", "User-Agent": "Mozilla/5.0 +signdict.org"],
             follow_redirect: true
           ) do
      Poison.decode!(res.body)
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

  defp find_or_create_user_for(username) do
    query = from(user in User, where: user.name == ^username)
    Repo.one(query) || Repo.insert!(%User{name: username})
  end

  defp download_file(%{"videoUrl" => video_url}) do
    url = URI.parse(video_url)
    file_name = Path.basename(url.path)
    File.mkdir(Path.join([System.tmp_dir(), "wps_importer"]))
    file = File.open!(Path.join([System.tmp_dir(), "wps_importer", file_name]), [:write])
    {:ok, _result} = Downstream.get(video_url, file)
    File.close(file)
    temp_file = Path.join([System.tmp_dir(), "wps_importer", file_name])

    VideoImporter.store_file(temp_file, Path.basename(temp_file))
  end

  defp find_or_create_entry_for(%{"fachbegriff" => text}) do
    language = find_or_create_language_for("DGS")

    language
    |> query_for_entry(text)
    |> Repo.one() || Repo.insert!(generate_entry(language, text))
  end

  def query_for_entry(language, text) do
    from(
      entry in Entry,
      where:
        entry.language_id == ^language.id and entry.text == ^text and
          (entry.description == "" or is_nil(entry.description))
    )
  end

  defp find_or_create_language_for(sign_language) do
    query = from(language in Language, where: language.short_name == ^sign_language)
    Repo.one(query) || Repo.insert!(%Language{short_name: sign_language})
  end

  defp find_or_create_config() do
    ImporterConfig.for("WPS") || Repo.insert!(%ImporterConfig{name: "WPS"})
  end

  def generate_entry(language, text) do
    domain = find_or_create_domain()
    %Entry{text: text, description: "", language: language, type: "word", domains: [domain]}
  end

  defp find_or_create_domain() do
    wps_domain = Application.get_env(:sign_dict, :wps_importer)[:domain]
    query = from(domain in Domain, where: domain.domain == ^wps_domain)
    Repo.one(query) || Repo.insert!(%Domain{domain: wps_domain})
  end

  defp touch_last_request_time(config, current_time) do
    updated_config =
      (config.configuration || %{})
      |> Map.put(:last_requested, Timex.format!(current_time, "{ISO:Extended:Z}"))

    config
    |> ImporterConfig.changeset(%{configuration: updated_config})
    |> Repo.update()
  end

  defp insert_or_update_video(entry, user, json_entry, exq) do
    video = find_by_external_id(json_entry["dokumentId"]) |> Repo.preload(:entry)

    if video do
      old_metadata = video.metadata

      video
      |> update_metadata(json_entry)
      |> move_to_other_entry_if_needed()
      |> transcode_video_if_needed(old_metadata, exq)
    else
      video_filename = download_file(json_entry)

      insert_video(entry, user, json_entry, video_filename)
      |> transcode_video(exq)
    end
  end

  defp find_by_external_id(external_id) do
    Repo.one(from v in Video, where: v.external_id == ^external_id)
  end

  defp insert_video(entry, user, json_entry, video_filename) do
    Repo.insert!(%Video{
      copyright: "sign2mint",
      license: "by-nc-sa/3.0/de",
      original_href: "https://delegs.de/",
      metadata: %{
        source_json: json_entry,
        source_mp4: video_filename
      },
      user: user,
      entry: entry,
      state: "uploaded",
      external_id: json_entry["dokumentId"],
      auto_publish: true
    })
  end

  defp transcode_video_if_needed(video, old_metadata, exq) do
    if video.metadata["source_json"]["videoUrl"] != old_metadata["source_json"]["videoUrl"] do
      video_filename = download_file(video.metadata["source_json"])

      video =
        video
        |> Video.changeset_uploader(%{
          metadata: Map.merge(video.metadata, %{"source_mp4" => video_filename}),
          state: "uploaded"
        })
        |> Repo.update!()

      transcode_video(video, exq)
    else
      video
    end
  end

  defp transcode_video(video, exq) do
    exq.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video.id])
    video
  end

  defp move_to_other_entry_if_needed(video) do
    if video.entry.text != video.metadata["source_json"]["fachbegriff"] do
      old_entry = video.entry
      entry = find_or_create_entry_for(video.metadata["source_json"])

      video =
        video
        |> Video.changeset_uploader(%{
          entry_id: entry.id
        })
        |> Repo.update!()

      Entry.update_current_video(old_entry)
      video
    else
      video
    end
  end

  defp update_metadata(video, json_entry) do
    video
    |> Video.changeset_uploader(%{
      metadata: Map.merge(video.metadata, %{"source_json" => json_entry})
    })
    |> Repo.update!()
  end
end
