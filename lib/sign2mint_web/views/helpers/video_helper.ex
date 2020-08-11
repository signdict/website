defmodule Sign2MintWeb.Helpers.VideoHelper do
  def department(%{metadata: %{"source_json" => %{"Fachgebiet:" => department}}}) do
    String.split(department, ",")
  end

  def department(_) do
    []
  end

  def color_for_department(department) do
    "s2m--colors--#{String.downcase(department)}"
  end

  def source(%{metadata: %{"source_json" => %{"Herkunft:" => source}}}) do
    String.split(source, ",")
  end

  def source(_) do
    []
  end

  def application(%{metadata: %{"source_json" => %{"Anwendungsbereich:" => application}}}) do
    String.split(application, ",")
  end

  def application(_) do
    []
  end

  def is_recommended(%{metadata: %{"source_json" => %{"Empfehlung:" => "X"}}}) do
    true
  end

  def is_recommended(_) do
    false
  end
end
