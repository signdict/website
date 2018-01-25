defmodule SignDict.Importer.JsonImporter do
  import Ecto.Query

  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.Repo
  alias SignDict.Services.VideoImporter
  alias SignDict.User
  alias SignDict.Video

  def import_json(json_file, exq \\ Exq) do
    json = json_file |> read_file |> decode_json
    user = find_or_create_user_for(json)
    entry = find_or_create_entry_for(json_file, json)
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

  defp find_or_create_entry_for(_filename, %{"word" => text}) do
    do_find_or_create_entry_for(text, nil)
  end

  defp find_or_create_entry_for(_filename, %{"text" => text, "description" => description}) do
    do_find_or_create_entry_for(text, description)
  end

  defp find_or_create_entry_for(filename, _params) do
    do_find_or_create_entry_for(Path.basename(filename, ".json"), nil)
  end

  defp do_find_or_create_entry_for(text, description) do
    language = find_or_create_language_for("dgs")

    query =
      if description == nil || String.length(description) == 0 do
        query_for_entry(language, text)
      else
        query_for_entry(language, text, description)
      end

    Repo.one(query) || Repo.insert!(generate_entry(language, text, description))
  end

  def generate_entry(language, text, description) do
    %Entry{text: text, description: description || "", language: language, type: "word"}
  end

  def query_for_entry(language, text, description) do
    from(
      entry in Entry,
      where:
        entry.language_id == ^language.id and entry.text == ^text and
          entry.description == ^description
    )
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
end
