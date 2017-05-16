defmodule SignDict.SharedView do
  use SignDict.Web, :view

  def ogtags(conn) do
    ogtags = Map.merge(%{
                "og:title" => "SignDict",
                "og:description" => "Ein Gebärdensprachlexikon",
                "og:type" => "website",
                "og:image" => "/images/logo.png",
                "og:url" => SignDict.Router.Helpers.url(conn) <> conn.request_path
              }, (conn.assigns[:ogtags] || %{}))
    render_metatags(ogtags)
  end

  defp render_metatags(tags) do
    for {key, value} <- tags do
      raw("\t<meta property=\"#{key}\" content=\"#{value}\">\n")
    end
  end

end
