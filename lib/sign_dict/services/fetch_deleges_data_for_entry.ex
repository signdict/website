defmodule SignDict.Services.FetchDelegesDataForEntry do
  alias SignDict.SignWriting
  alias SignDict.Entry
  alias SignDict.Repo

  import Ecto.Query

  def fetch_for(entry, http_poison \\ HTTPoison) do
    result =
      http_poison.get!(
        "https://server.delegs.de/delegseditor/signwritingeditor/signitems?word=#{URI.encode(entry.text)}"
      )

    if result.status_code == 200 do
      entry
      |> parse_data(result.body)
      |> delete_outdated_items(entry)
      |> fetch_images(http_poison)

      entry
      |> Entry.deleges_updated_at_changeset(%{deleges_updated_at: DateTime.utc_now()})
      |> Repo.update!()
    end
  end

  defp parse_data(entry, body) do
    body
    |> String.slice(1, String.length(body) - 2)
    |> Jason.decode!()
    |> Enum.map(fn data ->
      %{
        deleges_id: String.to_integer(data["id"]),
        width: String.to_integer(data["width"]),
        word: data["word"],
        entry_id: entry.id
      }
    end)
    |> Enum.map(fn entry ->
      entry.deleges_id
      |> find_sign_writing()
      |> create_or_update_sign_writing(entry)
    end)
  end

  defp create_or_update_sign_writing(nil, entry) do
    %SignWriting{}
    |> SignWriting.changeset(entry)
    |> Repo.insert!()
  end

  defp create_or_update_sign_writing(sign_writing, entry) do
    sign_writing
    |> SignWriting.changeset(Map.delete(entry, :entry_id))
    |> Repo.update!()
  end

  defp find_sign_writing(deleges_id) do
    SignDict.Repo.get_by(SignWriting, deleges_id: deleges_id)
    |> SignDict.Repo.preload(:entry)
  end

  defp fetch_images(sign_writings, http_poison) do
    sign_writings
    |> Enum.filter(fn writing -> writing.state == "active" end)
    |> Enum.sort_by(& &1.deleges_id)
    |> Enum.take(5)
    |> Enum.each(fn writing -> fetch_image(writing, http_poison) end)
  end

  defp fetch_image(sign_writing, http_poison) do
    result =
      http_poison.get!(
        "https://server.delegs.de/delegseditor/signwritingeditor/signimages?upperId=#{sign_writing.deleges_id}&lowerId=#{URI.encode(sign_writing.word)}&signlocale=DGS",
        %{
          "If-Modified-Since" => last_modified_of(sign_writing)
        }
      )

    if result.status_code == 200 do
      {:ok, filename} = Briefly.create()
      File.write!(filename, result.body)

      SignWriting.changeset(sign_writing, %{
        image: %Plug.Upload{
          content_type: "image/png",
          filename: "file.png",
          path: filename
        }
      })
      |> Repo.update!()
    end
  end

  defp delete_outdated_items(sign_writings, entry) do
    deleges_ids = Enum.map(sign_writings, & &1.deleges_id)
    entry_id = entry.id

    SignWriting
    |> where([p], p.entry_id == ^entry_id and p.deleges_id not in ^deleges_ids)
    |> Repo.delete_all()

    sign_writings
  end

  defp last_modified_of(%SignWriting{image: nil}) do
    nil
  end

  defp last_modified_of(sign_writing) do
    Timex.format!(Timex.to_datetime(sign_writing.updated_at, "GMT"), "{RFC1123}")
  end
end
