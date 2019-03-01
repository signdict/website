defmodule SignDict.Services.FetchDelegesDataFroEntry do
  alias SignDict.SignWriting

  def fetch_for(entry) do
    # TODO: do not execute when last update younger than three days
    result =
      HTTPoison.get!(
        "https://server.delegs.de/delegseditor/signwritingeditor/signitems?word=#{
          URI.encode(entry.text)
        }"
      )

    if result.status_code == 200 do
      parse_data(entry, result.body)
      |> fetch_images()
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
      sign_writing = find_sign_writing(entry.deleges_id)

      if sign_writing do
        sign_writing
        |> SignWriting.changeset(Map.delete(entry, :entry_id))
        |> SignDict.Repo.update!()
      else
        %SignWriting{}
        |> SignWriting.changeset(entry)
        |> SignDict.Repo.insert!()
      end
    end)
  end

  defp find_sign_writing(deleges_id) do
    SignDict.Repo.get_by(SignWriting, deleges_id: deleges_id)
    |> SignDict.Repo.preload(:entry)
  end

  defp fetch_images(sign_writings) do
    # TODO: fetch the images
  end
end
