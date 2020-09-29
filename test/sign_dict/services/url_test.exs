defmodule SignDict.Services.UrlTest do
  use SignDict.ModelCase, async: true

  alias SignDict.Services.Url

  describe "for_entry21" do
    test "adds correct url to entry" do
      assert Url.for_entry(%SignDict.Entry{id: "1"}, "localhost").url ==
               "https://localhost/entry/1"
    end

    test "adds correct url to videos" do
      entry = %SignDict.Entry{id: "1", videos: [%SignDict.Video{id: "2"}]}

      assert List.first(Url.for_entry(entry, "localhost").videos).url ==
               "https://localhost/entry/1/video/2"
    end

    test "doest not crash on nil input" do
      refute Url.for_entry(nil, "localhost")
    end
  end

  describe "base_url_form_conn/1" do
    test "it should return a base url without a port if the port is a default one" do
      assert Url.base_url_from_conn(%Plug.Conn{host: "example.com", port: 80, scheme: :http}) ==
               "http://example.com"
    end

    test "it should return a base url with port if the port is not a default one" do
      assert Url.base_url_from_conn(%Plug.Conn{host: "example.com", port: 4000, scheme: :https}) ==
               "https://example.com:4000"
    end
  end
end
