defmodule SignDictWeb.Helpers.LayoutHelper do
  def get_layout_for(domain, layout) do
    if domain in ["sign2mint.local", "sign2mint.signdict.org"] do
      "sign2mint_" <> layout
    else
      layout
    end
  end
end
