defmodule SignDict.Services.Blank do
  def blank?(nil) do
    true
  end

  def blank?(string) do
    str_len =
      string
      |> String.trim()
      |> String.length()

    str_len == 0
  end
end
