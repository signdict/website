defmodule Sign2MintWeb.Helpers.VideoHelper do
  def department(entry) do
  end

  def color_for_department(entry) do
  end

  def source(entry) do
  end

  def application(entry) do
  end

  def is_recommended(%{metadata: %{"source_json" => %{"Empfehlung:" => "X"}}}) do
    true
  end

  def is_recommended(_) do
    false
  end
end
