defmodule SignDict.Importer.Wps.Wiktionary do
  def extract_description(url, number, http_lib \\ HTTPoison) do
    url
    |> generate_api_url()
    |> fetch_wikitext(http_lib)
    |> fetch_description(number)
    |> to_plaintext()
  end

  defp generate_api_url(wiki_url) do
    partials =
      Regex.named_captures(
        ~r/https:\/\/(?<country>[^\.]*)\.wiktionary.org\/wiki\/(?<word>[^?]*).*/,
        wiki_url
      )

    "https://#{partials["country"]}.wiktionary.org/w/api.php?action=parse&#{
      URI.encode_query(%{page: partials["word"]})
    }&prop=wikitext&formatversion=2&format=json"
  end

  defp fetch_wikitext(url, http_lib) do
    result = http_lib.get!(url)

    if result.status_code == 200 do
      Poison.decode!(result.body)["parse"]["wikitext"] || ""
    else
      ""
    end
  end

  defp fetch_description(wikitext, number) do
    Regex.named_captures(
      ~r/{{Bedeutungen}}.*?(\n:\[#{number}\](?<text>[^\n]*).*)/s,
      wikitext
    )["text"]
  end

  defp to_plaintext(wikitext) do
    wikitext
    |> remove_text("[[", "]]", "\\[\\[", "\\]\\]")
    |> remove_text("''", "''")
    |> remove_text("*", "*", "\\*", "\\*")
    |> replace_categorie()
  end

  defp remove_text(text, start_str, end_str) do
    remove_text(text, start_str, end_str, start_str, end_str)
  end

  defp remove_text(text, start_str, end_str, start_reg, end_reg) do
    (text || "")
    |> String.split(Regex.compile!("#{start_reg}.*?#{end_reg}"), include_captures: true)
    |> Enum.map(fn item ->
      if String.starts_with?(item, start_str) && String.ends_with?(item, end_str) do
        String.slice(
          item,
          String.length(start_str),
          String.length(item) - String.length(start_str) - String.length(end_str)
        )
      else
        item
      end
    end)
    |> Enum.join()
    |> String.trim()
  end

  defp replace_categorie(text) do
    text
    |> String.split(Regex.compile!("{{.*?}}"), include_captures: true)
    |> Enum.map(fn item ->
      if String.starts_with?(item, "{{") && String.ends_with?(item, "}}") do
        value =
          String.slice(
            item,
            2..-3
          )
          |> String.split("|")
          |> Enum.drop(1)
          |> Enum.join(", ")

        value <> ":"
      else
        item
      end
    end)
    |> Enum.join()
    |> String.trim()
  end
end
