defmodule SignDict.SharedView do
  use SignDict.Web, :view

  def ogtags(assigns) do
    if assigns[:ogtags] do
      for {key, value} <- assigns[:ogtags] do
        raw("\t<meta property=\"#{key}\" content=\"#{value}\">\n")
      end
    else
      raw("""
      <meta property="og:title" content="SignDict" />
      <meta property="og:description" content="Ein Gebärdensprachlexikon" />
      <meta property="og:type" content="website" />
      <meta property="og:image" content="http://8aa627d7.ngrok.io/images/logo.png" />
      <meta property="og:url" content="http://8aa627d7.ngrok.io" />
      """)
    end
  end

end
