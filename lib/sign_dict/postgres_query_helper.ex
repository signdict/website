defmodule SignDict.PostgresQueryHelper do

  def format_search_query(search) do
    search
    |> String.split(~r/((?<!\s)b(?!\s)|\s)/)
    |> Enum.map(fn(word) -> "#{word}:*" end)
    |> Enum.join("&")
  end

end
