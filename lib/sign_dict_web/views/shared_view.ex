defmodule SignDictWeb.SharedView do
  use SignDictWeb, :view

  alias SignDictWeb.Router.Helpers
  alias Phoenix.HTML

  def ogtags(conn) do
    description = gettext("A sign language dictionary")
    image_url = Helpers.url(conn) <> "/images/logo.png"

    ogtags =
      Map.merge(
        %{
          "og:title" => title(conn),
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
      raw("<meta property=\"#{key}\" content=\"#{safe_value}\">\n")
    end
  end

  defp title(%{assigns: %{title: title}}) do
    "SignDict - #{title}"
  end

  defp title(_args) do
    "SignDict"
  end
end
