defmodule SignDict.PostgresQueryHelper do
  def format_search_query(search) do
    search
    |> String.replace(~r/\W/u, " ")
    |> String.split()
    |> Enum.filter(fn word -> String.length(word) > 0 end)
    |> Enum.map(fn word -> "#{word}:*" end)
    |> Enum.join("&")
  end
end
