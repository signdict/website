defmodule SignDict.Permalink do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def to_permalink(id, string) do
    "#{id}-#{cleanup_string(string)}"
  end

  defp cleanup_string(string) do
    (string || "")
    |> String.downcase
    |> String.replace(~r/[^\w-]+/u, "-")
    |> String.replace(~r/-$/, "")
  end
end
