defmodule SignDict.SharedView do
  use SignDict.Web, :view

  def ogtags(conn) do
    ogtags = Map.merge(%{
                "og:title" => title(conn),
                "og:description" => gettext("A sign language dictionary"),
                "og:type" => "website",
                "og:image" => SignDict.Router.Helpers.url(conn) <> "/images/logo.png",
                "og:url" => SignDict.Router.Helpers.url(conn) <> conn.request_path
              }, (conn.assigns[:ogtags] || %{}))
    render_metatags(ogtags)
  end

  defp render_metatags(tags) do
    for {key, value} <- tags do
      raw("<meta property=\"#{key}\" content=\"#{value}\">\n")
    end
  end

  defp title(conn) do
    "SignDict" <> if conn.assigns[:title] do
      " - " <> conn.assigns[:title]
    end
  end

end
