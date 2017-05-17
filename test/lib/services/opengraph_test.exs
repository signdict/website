defmodule SignDict.Services.OpenGraphTest do
  use SignDict.ModelCase, async: true

  import SignDict.Factory

  test "it generates metadata for users" do
    user = insert(:user)
    result = SignDict.Services.OpenGraph.to_metadata(user)
    assert result["og:description"] == "   Jane Smith is a user on SignDict, a sign language dictionary.\n"
    assert result["og:image"] =~ "https://secure.gravatar.com/avatar/"
    assert result["og:image:secure_url"] =~ "https://secure.gravatar.com/avatar/"
  end

  test "it generates metadata for videos with a copyright line" do
    video= insert(:video_with_entry)
    result = SignDict.Services.OpenGraph.to_metadata(video.entry, video)
    assert result == %{
      "og:description" => "This video shows the sign of \"some content\". " <>
                          "See more Signs on SignDict.org,\nyour sign " <>
                          "language dictionary.\nLicense: license " <>
                          "by copyright - Jane Smith\n",
      "og:image" => "http://example.com/video.jpg",
      "og:image:secure_url" => "https://example.com/video.jpg",
      "og:type" => "video.other", "og:video:height" => 720,
      "og:video:secure_url" => "https://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "og:video:type" => "text/html",
      "og:video:url" => "http://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "og:video:width" => 1280
    }
  end

  test "it generates metadata for videos without a copyright line" do
    video= insert(:video_with_entry, copyright: nil)
    result = SignDict.Services.OpenGraph.to_metadata(video.entry, video)
    assert result == %{
      "og:description" => "This video shows the sign of \"some content\". " <>
                          "See more Signs on SignDict.org,\nyour sign " <>
                          "language dictionary.\nLicense: license " <>
                          "by Jane Smith\n",
      "og:image" => "http://example.com/video.jpg",
      "og:image:secure_url" => "https://example.com/video.jpg",
      "og:type" => "video.other", "og:video:height" => 720,
      "og:video:secure_url" => "https://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "og:video:type" => "text/html",
      "og:video:url" => "http://localhost:4001/embed/#{video.entry.id}-some-content/video/#{video.id}",
      "og:video:width" => 1280
    }
  end
end
