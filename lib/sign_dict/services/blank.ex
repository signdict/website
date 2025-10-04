defmodule SignDict.Services.Blank do
  def is_blank?(nil) do
    true
  end

  def is_blank?(string) do
    str_len =
      string
      |> String.trim()
      |> String.length()

    str_len == 0
  end
end
