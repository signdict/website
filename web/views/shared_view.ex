defmodule SignDict.SharedView do
  use SignDict.Web, :view

  def ogtags(assigns) do
    if assigns[:ogtags] do
      for {key, value} <- assigns[:ogtags] do
        raw("\t<meta property=\"#{key}\" content=\"#{value}\">\n")
      end
    else
      raw("\t<meta property=\"fb:app_id\" content=\"430839153628230\">\n")
    end
  end

end
