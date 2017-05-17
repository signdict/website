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
      {:safe, safe_value} = Phoenix.HTML.html_escape(value)
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
