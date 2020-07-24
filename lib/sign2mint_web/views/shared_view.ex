defmodule Sign2MintWeb.SharedView do
  use Sign2MintWeb, :view

  import SignDict.OpengraphTags

  def select_options(options, selected) do
    Enum.map(options, fn option ->
      {value, content} = option

      content_tag(:option, content,
        value: value,
        selected: selected != nil && is_list(selected) && Enum.member?(selected, value)
      )
    end)
  end
end
