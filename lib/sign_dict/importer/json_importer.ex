defmodule SignDict.Importer.JsonImporter do
  import Ecto.Query

  alias Ecto.UUID
  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.Video
  alias SignDict.User
  alias SignDict.Repo

  def import_json(json_file, exq \\ Exq) do
    json           = json_file |> read_file |> decode_json
    user           = find_or_create_user_for(json)
    entry          = find_or_create_entry_for(json_file, json)
    video_filename = Path.dirname(json_file) <> "/" <>
                     Path.basename(json["filename"])
    filename       = import_video(video_filename)

    video = Repo.insert!(%Video{
      copyright: "#{json["author"]} - #{json["source"]}",
      license: json["license"],
      original_href: json["word_link"],
      metadata: %{
        source_json: json,
        source_mp4:  filename
      },
      user: user,
      entry: entry,
      state: "uploaded"
    })
    exq.enqueue(Exq, "transcoder", SignDict.Worker.TranscodeVideo, [video.id])
    video
  end

  defp read_file(file) do
    {:ok, json_data} = file |> File.read
    json_data
  end

  defp decode_json(json) do
    Poison.decode!(json)
  end

  defp import_video(filename) do
    file = "#{UUID.generate}-#{Path.basename(filename)}"
    file_with_path = Path.join([paths_for_file(file), file])
    upload_path = Path.expand(Application.get_env(:sign_dict, :upload_path))
    target_file = Path.join([upload_path, "video_upload", file_with_path])
    File.mkdir_p(Path.dirname(target_file))
    File.rename(filename, target_file)
    file_with_path
  end

  defp paths_for_file(filename) do
    Path.join([
      String.slice(filename, 0..1),
      String.slice(filename, 2..3),
      String.slice(filename, 4..5)
    ])
  end

  defp find_or_create_user_for(%{"source" => username}) do
    query = from(user in User, where: user.name == ^username)
    Repo.one(query) || Repo.insert!(%User{name: username})
  end

  defp find_or_create_entry_for(_filename, %{"word" => text}) do
    do_find_or_create_entry_for(text, nil)
  end
  defp find_or_create_entry_for(_filename, %{"text" => text,
                                             "description" => description}) do
    do_find_or_create_entry_for(text, description)
  end
  defp find_or_create_entry_for(filename, _params) do
    do_find_or_create_entry_for(Path.basename(filename, ".json"), nil)
  end

  defp do_find_or_create_entry_for(text, description) do
    language = find_or_create_language_for("dgs")
    query = if description == nil || String.length(description) == 0 do
      query_for_entry(language, text)
    else
      query_for_entry(language, text, description)
    end
    Repo.one(query) || Repo.insert!(
                         generate_entry(language, text, description)
                       )
  end

  def generate_entry(language, text, description) do
    %Entry{text: text, description: (description || ""),
           language: language, type: "word"}
  end

  def query_for_entry(language, text, description) do
    from(entry in Entry, where: entry.language_id == ^language.id and
                     entry.text == ^text and entry.description == ^description)
  end
  def query_for_entry(language, text) do
    from(entry in Entry, where: entry.language_id == ^language.id and
                     entry.text == ^text and
                     (entry.description == "" or is_nil(entry.description)))
  end

  defp find_or_create_language_for(sign_language) do
    query = from(language in Language,
            where: language.short_name  == ^sign_language)
    Repo.one(query) || Repo.insert!(%Language{short_name: sign_language})
  end

end
