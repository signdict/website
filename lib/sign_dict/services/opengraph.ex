defprotocol SignDict.Services.OpenGraph do
  def to_metadata(model, sub_model \\ %{})

end

defimpl SignDict.Services.OpenGraph, for: SignDict.User do
  import SignDict.Gettext
  def to_metadata(user, _sub_model \\ %{}) do
    thumbnail_url = SignDict.User.avatar_url(user)
    %{
      "og:image"            => thumbnail_url,
      "og:image:secure_url" => String.replace(thumbnail_url, "http://", "https://"),
      "og:description"      => gettext("""
         %{user} is a user on SignDict, a sign language dictionary.
      """, user: user.name)
    }
  end
end

defimpl SignDict.Services.OpenGraph, for: SignDict.Entry do
  import SignDict.Gettext
  import SignDict.Router.Helpers
  def to_metadata(entry, video) do
    %{
      "og:description"      => description(entry, video),
      "og:image"            => video.thumbnail_url,
      "og:image:secure_url" => secure_url(video.thumbnail_url),
      "og:type"             => "video.other",
      "og:video:url"        => embed_video_url(SignDict.Endpoint, :show, entry, video),
      "og:video:secure_url" => secure_url(embed_video_url(SignDict.Endpoint, :show, entry, video)),
      "og:video:type"       => "text/html",
      "og:video:width"      => 1280,
      "og:video:height"     => 720,
    }
  end

  defp description(entry, video) do
    gettext("""
      This video shows the sign of "%{sign}". See more Signs on SignDict.org,
      your sign language dictionary.
      License: %{license} %{copyright}
      """,
      sign: entry.text, license: video.license,
      copyright: copyright(video)
    )
  end

  defp copyright(video) do
    if String.length(video.copyright || "") > 0 do
      gettext("by %{copyright} - %{username}", copyright: video.copyright, username: video.user.name)
    else
      gettext("by %{copyright}", copyright: video.user.name)
    end
  end

  defp secure_url(url) do
    String.replace(url, "http://", "https://")
  end
end
