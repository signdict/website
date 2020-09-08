defmodule Sign2MintWeb.Helpers.VideoHelper do
  def department(%{metadata: %{"filter_data" => %{"fachgebiet" => department}}}) do
    department
  end

  def department(_) do
    []
  end

  def color_for_department(department) do
    "s2m--colors--#{String.downcase(department)}"
  end

  def source(%{metadata: %{"filter_data" => %{"herkunft" => source}}}) do
    source
  end

  def source(_) do
    []
  end

  def application(%{metadata: %{"filter_data" => %{"anwendungsbereich" => application}}}) do
    application
  end

  def application(_) do
    []
  end

  def is_recommended(%{metadata: %{"source_json" => %{"metadata" => %{"Empfehlung:" => "X"}}}}) do
    true
  end

  def is_recommended(_) do
    false
  end
end
