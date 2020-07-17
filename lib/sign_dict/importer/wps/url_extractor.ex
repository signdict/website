defmodule SignDict.Importer.Wps.UrlExtractor do
  def extract(url)

  def extract(nil) do
    nil
  end

  def extract("[]") do
    nil
  end

  def extract(url) do
    Regex.named_captures(~r/\[(?<url>[^,]*).*\]/, url)["url"]
  end
end
