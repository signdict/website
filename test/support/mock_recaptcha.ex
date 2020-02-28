defmodule SignDict.MockRecaptcha do
  def verify("working") do
    {:ok, "sendemail"}
  end

  def verify(_param) do
    {:error, "wrong"}
  end
end
