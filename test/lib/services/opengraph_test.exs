defmodule SignDict.Services.OpenGraphTest do
  use SignDict.ModelCase, async: true

  import SignDict.Factory

  test "it generates metadata for users" do
    user = insert(:user)
    result = SignDict.Services.OpenGraph.to_metadata(user)
    assert result["og:description"]      == "Jane Smith is a user on SignDict, a sign language dictionary."
    assert result["og:image"]            =~ "https://secure.gravatar.com/avatar/"
    assert result["og:image:secure_url"] =~ "https://secure.gravatar.com/avatar/"
    assert result["twitter:card"]        == "summary"
    assert result["twitter:description"] == "Jane Smith is a user on SignDict, a sign language dictionary."
    assert result["twitter:image"]       =~ "https://secure.gravatar.com/avatar/"
    assert result["twitter:site"]        == "@SignDict"
  end

  test "it generates metadata for videos with a copyright line" do
    video= insert(:video_with_entry)
    result = SignDict.Services.OpenGraph.to_metadata(video.entry, video)
    assert %{
      "og:description" => "This video shows the sign of \"some content\". " <>
                          "See more Signs on SignDict.org, your sign " <>
                          "language dictionary. License: license " <>
                          "by copyright - Jane Smith",
      "og:image" => "http://example.com/video.jpg",
      "og:image:secure_url" => "https://example.com/video.jpg",
      "og:type" => "video.other", "og:video:height" => 720,
      "og:video:secure_url" => "http://example.com/video.mp4",
      "og:video:type" => "video/mp4",
      "og:video:url" => "http://example.com/video.mp4",
      "og:video:width" => 1280,
      "twitter:card" => "player",
      "twitter:description" => "This video shows the sign of \"some content\". See more Signs on SignDict.org, your sign language dictionary. License: license by copyright - Jane Smith",
      "twitter:player:height" => 350,
      "twitter:image" => "http://example.com/video.jpg",
      "twitter:player" => "https://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "twitter:site" => "@SignDict",
      "twitter:player:width" => 480
    } == result
  end

  test "it generates metadata for videos without a copyright line" do
    video= insert(:video_with_entry, copyright: nil)
    result = SignDict.Services.OpenGraph.to_metadata(video.entry, video)
    assert result == %{
      "og:description" => "This video shows the sign of \"some content\". " <>
                          "See more Signs on SignDict.org, your sign " <>
                          "language dictionary. License: license " <>
                          "by Jane Smith",
      "og:image" => "http://example.com/video.jpg",
      "og:image:secure_url" => "https://example.com/video.jpg",
      "og:type" => "video.other", "og:video:height" => 720,
      "og:video:secure_url" => "http://example.com/video.mp4",
      "og:video:type" => "video/mp4",
      "og:video:url" => "http://example.com/video.mp4",
      "og:video:width" => 1280,
      "twitter:card" => "player",
      "twitter:description" => "This video shows the sign of \"some content\". See more Signs on SignDict.org, your sign language dictionary. License: license by Jane Smith",
      "twitter:player:height" => 350,
      "twitter:image" => "http://example.com/video.jpg",
      "twitter:player" => "https://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "twitter:site" => "@SignDict",
      "twitter:player:width" => 480
    }
  end
end
