defmodule SignDict.OpengraphTags do
  use Gettext, backend: SignDictWeb.Gettext

  alias SignDictWeb.Router.Helpers
  alias Phoenix.HTML

  def ogtags(conn, default_title) do
    description = gettext("A sign language dictionary")
    image_url = Helpers.url(conn) <> "/images/logo.png"

    ogtags =
      Map.merge(
        %{
          "og:title" => title(conn, default_title),
          "og:description" => description,
          "og:type" => "website",
          "og:image" => image_url,
          "og:url" => Helpers.url(conn) <> conn.request_path,
          "twitter:card" => "summary",
          "twitter:site" => "@SignDict",
          "twitter:description" => description,
          "twitter:image" => String.replace(image_url, "http://", "https://")
        },
        conn.assigns[:ogtags] || %{}
      )

    render_metatags(ogtags)
  end

  defp render_metatags(tags) do
    for {key, value} <- tags do
      {:safe, safe_value} = HTML.html_escape(value)
      Phoenix.HTML.raw("<meta property=\"#{key}\" content=\"#{safe_value}\">\n")
    end
  end

  defp title(%{assigns: %{title: title}}, default_title) do
    "#{default_title} - #{title}"
  end

  defp title(_args, default_title) do
    default_title
  end
end
