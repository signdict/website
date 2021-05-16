defmodule SignDictWeb.Helpers.LayoutHelper do
  def render_shared(file, params) do
    Phoenix.View.render(SignDictWeb.SharedView, file, params)
  end
end
