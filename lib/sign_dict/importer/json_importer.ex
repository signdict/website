defmodule SignDict.Importer.JsonImporter do
  import Ecto.Query

  alias SignDict.Domain
  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.Repo
  alias SignDict.Services.VideoImporter
  alias SignDict.User
  alias SignDict.Video

  def import_json(json_file, exq \\ Exq) do
    json = json_file |> read_file |> decode_json
    user = find_or_create_user_for(json)
    domain = find_or_create_domain_for("signdict.org")
    entry = find_or_create_entry_for(json_file, json, domain)
    video_filename = Path.dirname(json_file) <> "/" <> Path.basename(json["filename"])
    filename = VideoImporter.store_file(video_filename, Path.basename(json["filename"]))

    video =
      Repo.insert!(%Video{
        copyright: "#{json["author"]} - #{json["source"]}",
        license: json["license"],
        original_href: json["word_link"],
        metadata: %{
          source_json: json,
          source_mp4: filename
        },
        user: user,
        entry: entry,
        state: "uploaded"
      })

    exq.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video.id])
    video
  end

  defp read_file(file) do
    {:ok, json_data} = file |> File.read()
    json_data
  end

  defp decode_json(json) do
    Poison.decode!(json)
  end

  defp find_or_create_user_for(%{"source" => username}) do
    query = from(user in User, where: user.name == ^username)
    Repo.one(query) || Repo.insert!(%User{name: username})
  end

  defp find_or_create_entry_for(_filename, %{"word" => text}, domain) do
    do_find_or_create_entry_for(text, nil, domain)
  end

  defp find_or_create_entry_for(
         _filename,
         %{"text" => text, "description" => description},
         domain
       ) do
    do_find_or_create_entry_for(text, description, domain)
  end

  defp find_or_create_entry_for(filename, _params, domain) do
    do_find_or_create_entry_for(Path.basename(filename, ".json"), nil, domain)
  end

  defp do_find_or_create_entry_for(text, description, domain) do
    language = find_or_create_language_for("DGS")

    query =
      if description == nil || String.length(description) == 0 do
        query_for_entry(language, text, domain)
      else
        query_for_entry(language, text, description, domain)
      end

    Repo.one(query) || Repo.insert!(generate_entry(language, text, description, domain))
  end

  def generate_entry(language, text, description, domain) do
    %Entry{
      text: text,
      description: description || "",
      language: language,
      type: "word",
      domains: [domain]
    }
  end

  def query_for_entry(language, text, description, domain) do
    from(
      entry in Entry,
      join: domain in Domain,
      where:
        entry.language_id == ^language.id and entry.text == ^text and
          entry.description == ^description and domain.id == ^domain.id
    )
  end

  def query_for_entry(language, text, domain) do
    from(
      entry in Entry,
      join: domain in Domain,
      where:
        entry.language_id == ^language.id and entry.text == ^text and
          (entry.description == "" or is_nil(entry.description)) and domain.id == ^domain.id
    )
  end

  defp find_or_create_language_for(sign_language) do
    query = from(language in Language, where: language.short_name == ^sign_language)
    Repo.one(query) || Repo.insert!(%Language{short_name: sign_language})
  end

  defp find_or_create_domain_for(url) do
    query = from(domain in Domain, where: domain.domain == ^url)
    Repo.one(query) || Repo.insert!(%Domain{domain: url})
  end
end
