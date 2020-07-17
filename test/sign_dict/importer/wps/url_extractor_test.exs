defmodule SignDict.Importer.Wps.UrlExtractorTest do
  use SignDict.ModelCase
  alias SignDict.Importer.Wps.UrlExtractor

  describe "extract/1" do
    test "it extracts a url from the string" do
      assert UrlExtractor.extract("[http://example.com]") == "http://example.com"
    end

    test "it extracts the first url from the string" do
      assert UrlExtractor.extract("[http://example.com,http://another.com]") ==
               "http://example.com"
    end

    test "it returns nil if the string is nil" do
      assert UrlExtractor.extract(nil) == nil
    end

    test "it returns nil if the string is empty" do
      assert UrlExtractor.extract("[]") == nil
    end

    test "it returns nil if the string is damaged" do
      assert UrlExtractor.extract("[http://example.com") == nil
    end
  end
end
