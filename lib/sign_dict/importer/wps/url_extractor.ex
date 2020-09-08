defmodule SignDict.Importer.Wps.UrlExtractor do
  def extract(url)

  def extract(nil) do
    nil
  end

  def extract([]) do
    nil
  end

  def extract([head | _]) do
    head
  end
end
