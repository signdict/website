defmodule SignDictWeb.Helpers.LayoutHelper do
  def get_layout_for(domain, layout) do
    # TODO: refactor this
    if domain in ["sign2mint.local"] do
      "sign2mint_" <> layout
    else
      layout
    end
  end
end
